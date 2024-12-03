import os
from flask import Flask, request, Response
import cv2
import numpy as np
from datetime import datetime
from returnalphaTEST import process_and_predict  # Import the encapsulated function

app = Flask(__name__)

# Ensure the 'images' directory exists
IMAGES_FOLDER = "images"
os.makedirs(IMAGES_FOLDER, exist_ok=True)

# Global variable to store the final word output
final_text = ""
last_detection_time = datetime.now()  # Track the last time a gesture was detected

# Gap threshold in seconds (e.g., 2 seconds without a new gesture means a gap)
GAP_THRESHOLD = 2  # 2 seconds

@app.route('/stream', methods=['POST'])
def stream():
    global final_text, last_detection_time  # Use the global final_text and last_detection_time

    try:
        # Read the frame from the POST request
        image_bytes = request.data
        nparr = np.frombuffer(image_bytes, np.uint8)
        frame = cv2.imdecode(nparr, cv2.IMREAD_COLOR)

        # Save the image with a timestamp
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S%f")
        filename = os.path.join(IMAGES_FOLDER, f"frame_{timestamp}.jpg")
        cv2.imwrite(filename, frame)

        # Process the image and get the predicted letter
        predicted_letter = process_and_predict(filename)
        print(f"Predicted letter: {predicted_letter}")

        # Get current time
        current_time = datetime.now()

        if predicted_letter:
            # If the predicted letter is valid, check if there's a gap (pause) between the last detection
            time_diff = (current_time - last_detection_time).total_seconds()

            if time_diff > GAP_THRESHOLD:
                # If there's a gap, return a space (" "), and reset the word buffer
                print("Gap detected! Adding space...")
                final_text += " "  # Add a space to the final_text
                print(f"Current word: {final_text}")
                predicted_letter = None  # Set predicted letter to None to indicate a gap
            else:
                # Otherwise, append the predicted letter to the final word
                final_text += predicted_letter
                print(f"Current word: {final_text}")

            # Update the last detection time
            last_detection_time = current_time

        # Return the predicted letter or a space
        if predicted_letter is None:
            return ""  # Return a space for a gap
        else:
            return predicted_letter  # Return the predicted letter

    except Exception as e:
        print(f"Error in stream endpoint: {e}")
        return Response(status=500)

@app.route('/reset', methods=['POST'])
def reset():
    global final_text
    final_text = ""  # Reset the word buffer
    return ""  # Returning a simple message instead of JSON

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
