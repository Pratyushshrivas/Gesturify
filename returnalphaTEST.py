import cv2
import os
import numpy as np
import math
import time
from cvzone.HandTrackingModule import HandDetector
from cvzone.ClassificationModule import Classifier

# Constants
IMG_SIZE = 300
OFFSET = 20
LABELS = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V",
          "W", "X", "Y", "Z"]
detector = HandDetector(maxHands=1)
classifier = Classifier("Model2/keras_model_compatible.h5", "Model2/labels.txt")

# Global variable to store the final text
final_text = ""


def process_and_predict(image_path):
    global final_text  # Declare final_text as global
    prediction_buffer = []  # Buffer to store the current word
    last_detection_time = time.time()

    try:
        img = cv2.imread(image_path)  # Read the image
        if img is None:
            print(f"Error reading image {image_path}.")
            return None

        hands, img = detector.findHands(img)  # Detect hands in the image
        current_time = time.time()

        if not hands:
            # If no hand detected, check if it's been 1 second since the last detection
            if current_time - last_detection_time > 1 and prediction_buffer:
                # Word completion: Add current buffer as a word and reset
                final_text += ''.join(prediction_buffer) + " "
                print(f"Word completed: {''.join(prediction_buffer)}")
                prediction_buffer = []  # Clear buffer for the next word
            return None  # Skip processing if no hands detected

        # Update the last detection time
        last_detection_time = current_time

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
        letter = LABELS[index]
        prediction_buffer.append(letter)

        print(f"Current word: {''.join(prediction_buffer)}")
        return letter
    except Exception as e:
        print(f"Error in process_and_predict: {e}")
        return None
    finally:
        # Clean up: Delete the image after processing
        if os.path.exists(image_path):
            os.remove(image_path)


def display_final_text():
    global final_text
    print(f"Final Text: {final_text.strip()}")
