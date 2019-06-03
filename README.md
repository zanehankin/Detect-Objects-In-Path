# Detect-Objects-In-Path
### Using camera to detect a safe route for walking!

> This is the app I built to help anybody who is visually impaired navigate their way. This app detects vertical surfaces and notifies you to turn either left or right depending which route has/does not have a vertical surface in your path. This app is also great for navigating through a maze!

### Process

> We were given an open assignment to build our own app. The two requirements were: <b> 1. Include any of the topics that we have covered so far</b> and <b>2. Incorporate an element of coding that we did not know how to do.</b> I was fascinated by our projects in Augmented Reality (AR), so I knew that I wanted my app to include elements of that. First requirement, <b>check</b>. Then, I needed to figure out what I was going to accomplish with my app. I looked through my class's <i>Topics Page</i> and stumbled upon a Ted Talk that we watched when we first began our unit on AR. In this <a href="https://www.ted.com/talks/joseph_redmon_how_a_computer_learns_to_recognize_objects_instantly?language=en">Ted Talk,</a> Joseph Redmon presented about a project he was working on in Graduate school called YOLO. It can detect and correctly identify everyday objects in real-time. I took Redmon's idea and combined it with the everyday task of walking. I figured out that I wanted to be able to walk and have an app direct me based on whether or not there are objects in my path. <b>"How was I going to do this??", I asked myself.</b>

> I started by researching the YOLO project on their <a href= "https://pjreddie.com/darknet/yolo/">website</a>, but unfortunately the developers were using a different platform to code on. From here, I deep dove into <a href= "https://developer.apple.com/documentation"> "Apple's Developer Documenation"</a> and trickled through the categroies of ARKit, through ARPlane Detection and all of its classes, properties, declarations, etc. Then, I found a tutorial on <a href= "https://collectiveidea.com/blog/archives/2018/04/30/part-1-arkit-wall-and-plane-detection-for-ios-11.3">Collective Idea</a> that could help me understand what "Plane Detection" was and how I could leverage it. 

> My first iteration of the app simply detected planes in the real world. Then, I narrowed down my plane detection to vertical surfaces only because I only wanted to detect  walls and objects in my path, not the ground or other horizontal surfaces. Next, I wrote code that took the angle of two points on the vertical plane that the program detected, and I applied that angle to a 3D arrow that appears on the screen. The arrow corrects itself so the angle is at 90°, thus aligning the camera and the viewer parallelly to the vertical plane.

### Having Fun While Learning
