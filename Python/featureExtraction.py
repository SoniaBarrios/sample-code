import marsyas
import matplotlib.pyplot as plt
import sys

# using part 6.2.3 - "Patching example of Feature extraction" in the Marsyas manual as a model
# http://marsyas.info/docs/manual/marsyas-user/Patching-example-of-Feature-extraction.html#Patching-example-of-Feature-extraction
# Connect a SoundFileSource, Windowing, Spectrum, PowerSpectrum and Centroid processing nodes
# type/name/data-type/attribute/

filename = sys.argv[1]

# for each song in the collection
# set the song to be the soundfilesource
# annotate all the centroids, annotate all the zero crossings
# repeatefor each song

# mean question is just mean after zero and mean after centroid
# get mean values for both of them

# determine label, Weka filename
breakup_filename = str(filename).rsplit('/')
breakup_filename = breakup_filename[1]
breakup_filename = str(breakup_filename).rsplit('.')

label = breakup_filename[0]
print label
weka_filename = breakup_filename[0]+"."+breakup_filename[1]+".arff"
sonify_filename = weka_filename.replace('.arff','.wav')

if label=='disco':
    label = 1.0
elif label=='classical':
    label = 0.0

# Set the number of samples to remember to running average
k = 256

# create top-levels
mng = marsyas.MarSystemManager()
s1 = mng.create("Series", "Series1")
fanout1 = mng.create("Fanout","Fanout1")
s2 = mng.create("Series", "Series2")
s3 = mng.create("Series", "Sonify")

# add the marsystems to series 2
s2.addMarSystem(mng.create("Windowing","Windowing"))                # create windowing object
s2.addMarSystem(mng.create("Spectrum","Spectrum"))                  # create a spectrum object
s2.addMarSystem(mng.create("PowerSpectrum","PwrSpec"))              # create a spectrum object
s2.addMarSystem(mng.create("Centroid","Centroid"))                  # create a cetroid object
s2.addMarSystem(mng.create("Gain","gain"))

# add the marsystems to the fanout series
fanout1.addMarSystem(mng.create("ZeroCrossings", "ZeroCrossings"))  # create a zero crossings object
fanout1.addMarSystem(s2)                                            # add series 2 to fanout 1

# add the marsystems to series 1
s1.addMarSystem(mng.create("SoundFileSource", "src"))               # create a sound source
s1.addMarSystem(fanout1)                                            # add fanout 1 to series 1
s1.addMarSystem(mng.create("Memory","mem"))                         # create memory of last k values
s1.addMarSystem(mng.create("Mean","mean"))                          # create an object that calculates the mean
s1.addMarSystem(mng.create("Annotator","Anno"))                     # Add an annotator
s1.addMarSystem(mng.create("WekaSink","wsink"))                     # add a Weka Sink

# add the marsystems to series 3
s3.addMarSystem(mng.create("SineSource","sin_src"))                 # create Sine Source
s3.addMarSystem(mng.create("SoundFileSink","SoundSink"))

# Update system controls
s2.updControl("Windowing/Windowing/mrs_natural/size", 512)          # set the window size to 512 smaples
s2.updControl("Gain/gain/mrs_real/gain",1.0)
s1.updControl("SoundFileSource/src/mrs_string/filename", filename)  # associate a file with the sound source
s1.updControl("SoundFileSource/src/mrs_real/frequency", 22050.0)    # set the sampling rate
s1.updControl("Memory/mem/mrs_natural/memSize", k)                  # Set the size of the circular buffer
s1.updControl("WekaSink/wsink/mrs_natural/nLabels",2)               # set the number of classification labels
s1.updControl("WekaSink/wsink/mrs_string/labelNames","classical,disco,")    # name the possible classes
s1.updControl("WekaSink/wsink/mrs_string/filename", marsyas.MarControlPtr.from_string(weka_filename)) # name the output Weka file
s1.updControl("Annotator/Anno/mrs_real/label",label)                # set the annotator label for this file
s3.updControl("SoundFileSink/SoundSink/mrs_string/filename",sonify_filename)

# make a list with as many values as samples/window size
centroid_values = []
zerocross_values = []

# process chucks of data from the sound file source
# get the zero-crossing and centroid over time
# iterate through
count = 0
while s1.getControl("SoundFileSource/src/mrs_bool/hasData").to_bool(): 
    s1.tick()   # increment each frame to process
    
    # store zero-crossing value for current frame
    zero_val = s1.getControl("mrs_realvec/processedData").to_realvec()[0]
    zerocross_values.append(zero_val)
    
    # store centroid value for current frame
    centroid_val = s1.getControl("mrs_realvec/processedData").to_realvec()[1]
    centroid_values.append(centroid_val)
# end while
