from tensorflow.keras.models import load_model
from tensorflow.keras.layers import DepthwiseConv2D

# Custom function to handle DepthwiseConv2D
def custom_depthwise_conv2d(*args, **kwargs):
    kwargs.pop('groups', None)  # Remove 'groups' if present
    return DepthwiseConv2D(*args, **kwargs)

# Load model with custom objects
model = load_model("ModelM/keras_model.h5", custom_objects={'DepthwiseConv2D': custom_depthwise_conv2d})
print("ModelM loaded successfully!")

model.save("ModelM/keras_model_compatible.h5")