import io
import logging
import os
import tempfile

import boto3
from PIL import Image
from selenium import webdriver
from selenium.webdriver.common.by import By

logger = logging.getLogger("trmnl")
logging.basicConfig(level=logging.INFO)

BUCKET = os.environ.get("BUCKET", "fi.erick.trmnl")

XPATH_SETTINGS = (
    (
        "forecast",
        "https://www.yr.no/nb/v%C3%A6rvarsel/graf/2-660561/Finland/Nyland/Porvoo/Borg%C3%A5",
        '//*[@id="forecast-page__graph"]',
    ),
    (
        "uv",
        "https://www.yr.no/nb/andre-varsler/2-660561/Finland/Nyland/Porvoo/Borg%C3%A5",
        "/html/body/div[1]/div/div/div[1]/div/div[2]/main/div[3]/div/div[3]/div/div/ol/li[1]/div",
    ),
    (
        "aurora",
        "https://www.yr.no/nb/andre-varsler/2-660561/Finland/Nyland/Porvoo/Borg%C3%A5",
        "/html/body/div[1]/div/div/div[1]/div/div[2]/main/div[3]/div/div[3]/div/div/ol/li[2]/div",
    ),
    (
        "sun",
        "https://www.yr.no/nb/andre-varsler/2-660561/Finland/Nyland/Porvoo/Borg%C3%A5",
        "/html/body/div[1]/div/div/div[1]/div/div[2]/main/div[3]/div/div[4]/div/div/ol/li[1]/div/div",
    ),
    (
        "moon",
        "https://www.yr.no/nb/andre-varsler/2-660561/Finland/Nyland/Porvoo/Borg%C3%A5",
        "/html/body/div[1]/div/div/div[1]/div/div[2]/main/div[3]/div/div[4]/div/div/ol/li[2]/div/div",
    ),
    (
        "electric",
        "https://nordpool.cc/fi/en/",
        "/html/body/div/div/div[1]/section/div/div[2]/div[1]/div[2]",
    ),
)


def save_screenshot(url: str, xpath: str, tempdir: str, filename: str) -> None:
    logging.info(f"\n{url=}\n{xpath=}\n{tempdir=}\n{filename=}\n")

    options = webdriver.FirefoxOptions()
    options.binary_location = "/usr/bin/firefox-esr"
    options.add_argument("--headless")
    service = webdriver.FirefoxService(
        executable_path="/usr/bin/geckodriver", driver_path_env_key="BINARYLOC"
    )
    driver = webdriver.Firefox(options=options, service=service)

    driver.get(url)
    image_binary = driver.find_element(By.XPATH, xpath).screenshot_as_png
    img = Image.open(io.BytesIO(image_binary))
    img.save(f"{tempdir}/{filename}")


def main() -> None:
    s3 = boto3.client("s3")

    with tempfile.TemporaryDirectory() as tempdir:
        for name, url, xpath in XPATH_SETTINGS:
            logging.info(f"Trying {name}...")
            save_screenshot(url, xpath, tempdir, f"{name}.png")
            logging.info("Generated. Now uploading...")
            s3.upload_file(
                f"{tempdir}/{name}.png",
                BUCKET,
                f"porvoo.{name}.latest.png",
            )
            logging.info("UV done.")


if __name__ == "__main__":
    logging.info("Starting...")
    main()
    logging.info("Done.")
