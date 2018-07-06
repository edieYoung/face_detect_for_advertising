# Face Detect For Advertising
This application is an iOS version of face-recognition based advertising application demo using Face++ SDK.
## Introduction
There are three parts of the advertising process. 

1. First is rating the advertisements serving as the training data. In the codes, the view controller will allow users to choose a piece of advertisement to watch and rate it as how much you like this ad. 

2. Second part is uploading both user's facial data acquired during watching and the rating score to the server. In this demo, it uses HTTP as uploading protocol and the data as parameter. So there is supposed to be a server application to respond to this request, and it will save the data respectively into the database with the format of the tables, which is in another repo.
3. Three is delivering the best-fit ad to users according to their facial features. This prediction will be done by a neural network model trained with the data collected in second part. Finally, the model will tell which ad is to be delivered to users.
## Other
1. This application is just for demo
2. The video resources are not included in this repo, so you need to put your test advertisements in to a specific fold and name them in consistance with codes in advance.
3. This demo should be allowed by users to using the camera of the devices firstly.
## Preview
![preview.gif](./preview.gif)


