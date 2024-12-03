import cv2
import os
import numpy as np
import math
from cvzone.HandTrackingModule import HandDetector
from cvzone.ClassificationModule import Classifier

# Constants
IMG_SIZE = 300
OFFSET = 20
LABELS = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V",
          "W", "X", "Y", "Z"]

# Initialize the HandDetector and Classifier
detector = HandDetector(maxHands=1)
classifier = Classifier("Model2/keras_model_compatible.h5", "Model2/labels.txt")

def process_and_predict(image_path):
    """
    Process the image at the given path and predict the letter.
    """
    try:
        img = cv2.imread(image_path)  # Read the image
        if img is None:
            print(f"Error reading image {image_path}.")
            return None

        hands, img = detector.findHands(img)  # Detect hands in the image
        if not hands:
            print(f"No hand detected in image {image_path}.")
            return None

        hand = hands[0]
        x, y, w, h = hand['bbox']

        # Prepare the cropped and resized image
        imgWhite = np.ones((IMG_SIZE, IMG_SIZE, 3), np.uint8) * 255
        imgCrop = img[y - OFFSET:y + h + OFFSET, x - OFFSET:x + w + OFFSET]

        if imgCrop.size == 0:
            print(f"Empty crop for image {image_path}.")
            return None

        aspectRatio = h / w
        if aspectRatio > 1:
            k = IMG_SIZE / h
            wCal = math.ceil(k * w)
            imgResize = cv2.resize(imgCrop, (wCal, IMG_SIZE))
            wGap = math.ceil((IMG_SIZE - wCal) / 2)
            imgWhite[:, wGap:wCal + wGap] = imgResize
        else:
            k = IMG_SIZE / w
            hCal = math.ceil(k * h)
            imgResize = cv2.resize(imgCrop, (IMG_SIZE, hCal))
            hGap = math.ceil((IMG_SIZE - hCal) / 2)
            imgWhite[hGap:hCal + hGap, :] = imgResize

        # Make the prediction
        prediction, index = classifier.getPrediction(imgWhite, draw=False)
        return LABELS[index]
    except Exception as e:
        print(f"Error in process_and_predict: {e}")
        return None
    finally:
        # Clean up: Delete the image after processing
        if os.path.exists(image_path):
            os.remove(image_path)
