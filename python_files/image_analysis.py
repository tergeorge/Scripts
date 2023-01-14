import urllib.request
from PIL import Image
import numpy as np
import skimage.io

import matplotlib.pyplot as plt

######################### Question 1######################################################

image_ch1 = skimage.io.imread(fname=r"C:\Users\Teresa George\Downloads\41077_120219_S000090_ch01.tif")
image_ch1 = np.asarray(image_ch1)
l = image_ch1.shape[0]
b= image_ch1.shape[1]
print('Data Type: %s' % image_ch1.dtype)
print('Min: %.3f, Max: %.3f' % (image_ch1.min(), image_ch1.max()))
# convert from integers to floats
image_ch1 = image_ch1.astype('float32')
# normalize to the range 0-1
image_ch1 /= 255.0
# confirm the normalization
print('Min: %.3f, Max: %.3f' % (image_ch1.min(), image_ch1.max()))
image_ch1_1D = image_ch1.reshape(image_ch1.shape[0]*image_ch1.shape[1])
histogram_image_1, bin_edges = np.histogram(image_ch1_1D,bins=np.arange(0, 256))

image_ch2 = skimage.io.imread(fname=r"C:\Users\Teresa George\Documents\TVI_interview\41077_120219_S000090_ch02.tif")
image_ch2 = np.asarray(image_ch2)
l = image_ch2.shape[0]
b= image_ch2.shape[1]
print('Data Type: %s' % image_ch2.dtype)
print('Min: %.3f, Max: %.3f' % (image_ch2.min(), image_ch2.max()))
# convert from integers to floats
image_ch2 = image_ch2.astype('float32')
# normalize to the range 0-1
image_ch2 /= 255.0
# confirm the normalization
print('Min: %.3f, Max: %.3f' % (image_ch2.min(), image_ch2.max()))
image_ch2_1D = image_ch2.reshape(image_ch2.shape[0]*image_ch2.shape[1])
histogram_image_2, bin_edges = np.histogram(image_ch2_1D,bins=np.arange(0, 256))

image_ch3 = skimage.io.imread(fname=r"C:\Users\Teresa George\Documents\TVI_interview\41077_120219_S000090_ch03.tif")
image_ch3 = np.asarray(image_ch3)
l = image_ch3.shape[0]
b= image_ch3.shape[1]
print('Data Type: %s' % image_ch3.dtype)
print('Min: %.3f, Max: %.3f' % (image_ch3.min(), image_ch3.max()))
# convert from integers to floats
image_ch3 = image_ch3.astype('float32')
# normalize to the range 0-1
image_ch3 /= 255.0
# confirm the normalization
print('Min: %.3f, Max: %.3f' % (image_ch3.min(), image_ch3.max()))
image_ch3_1D = image_ch3.reshape(image_ch3.shape[0]*image_ch3.shape[1])
histogram_image_3, bin_edges = np.histogram(image_ch3_1D,bins=np.arange(0, 256))

plt.figure(1)
plt.subplot(2,3,1)
plt.title(" Histogram image 1")
plt.xlabel("pixel value")
plt.ylabel("pixel count")
plt.yscale('log')
plt.plot(bin_edges[0:-1], histogram_image_1)  

plt.subplot(2,3,2)
plt.title(" Histogram image 2")
plt.xlabel("pixel value")
plt.ylabel("pixel count")
plt.yscale('log')
plt.plot(bin_edges[0:-1], histogram_image_2) 

plt.subplot(2,3,3)
plt.title(" Histogram image 3")
plt.xlabel("pixel value")
plt.ylabel("pixel count")
plt.yscale('log')
plt.plot(bin_edges[0:-1], histogram_image_3)  

plt.subplot(2,3,4)
plt.title("Image 1")
plt.imshow(image_ch1)

plt.subplot(2,3,5)
plt.title("Image 2")
plt.imshow(image_ch2)

plt.subplot(2,3,6)
plt.title("Image 3")
plt.imshow(image_ch3)# <- or here
plt.show()


######################### Question 2##############################################
import cv2
import numpy as np

image_mask = skimage.io.imread(fname=r"C:\Users\Teresa George\Documents\TVI_interview\binary_41077_120219_S000090_L01.tif")
image_mask = np.asarray(image_mask)
image_mask = image_mask.astype('float32')
image_mask_1D = image_mask.reshape(image_mask.shape[0]*image_mask.shape[1])
image_mask_1D /= 255.0
histogram_mask, bin_edges = np.histogram(image_mask_1D,bins=np.arange(0, 256))


image_new = image_ch3 - image_ch1
mask = cv2.inRange(image_new, 10, 255) 

# apply morphology to remove isolated extraneous noise
# use borderconstant of black since foreground touches the edges
kernel = np.ones((3,3), np.uint8)
mask = cv2.morphologyEx(mask, cv2.MORPH_OPEN, kernel)
mask = cv2.morphologyEx(mask, cv2.MORPH_CLOSE, kernel)


plt.figure(2)
plt.subplot(1,2,1)
plt.title("Mask of image generated")
plt.imshow(mask)
plt.subplot(1,2,2)
plt.title("Ground truth mask")
plt.imshow(image_mask)
plt.show()

from sklearn.metrics import mean_squared_error
print("MSE: ", mean_squared_error(mask,image_mask))

########################### Question 3 #################################

# initialize feature detector
detector = cv2.ORB_create()
# use the mask and grayscale images to detect good features
#orb = cv2.ORB_create(nlevels=8, fastThreshold=20, scaleFactor=1.2, WTA_K=2,scoreType=cv2.ORB_HARRIS_SCORE, firstLevel=0, nfeatures=500)
#kp2 = orb.detect(mask)


orb = cv2.ORB_create()
orb.setScoreType(cv2.FAST_FEATURE_DETECTOR_TYPE_9_16)
orb.setWTA_K(3)
    
# detect keypoints
kp = orb.detect(mask,None)

    # for detected keypoints compute descriptors. 
kp, des = orb.compute(mask, kp)
img2_kp = cv2.drawKeypoints(mask, kp, None, color=(0,255,0), \
       flags=cv2.DrawMatchesFlags_DEFAULT)

plt.figure(3)
plt.imshow(img2_kp)
plt.show()
print(des)

