## Introduction

Driver drowsiness is a safety-critical problem, as it causes unsafe driving conditions by lowering reaction times, reducing attention, and impairing decision-making. 

* **The Impact:** An estimated **17.6% of fatal crashes** in the United States from 2017 to 2021 involved a drowsy or tired driver, resulting in approximately **30,000 deaths** during that period. 
* **Our Solution:** We are building a proactive system designed to reduce fatigue-related accidents. 
* **How it Works:** The system captures visual data of the driver and makes real-time inferences based on their body language. This keeps the driver in check, ensuring they are neither tired nor drowsy during their trip, which ultimately reduces mistakes.
* **Safety Precaution:** Fleet operators are integrated into the system as an extra layer of precaution. If a driver is drowsy and fails to stop and rest, the fleet operator will intervene and remind the driver to pull over, preventing accidents and keeping the roads safe.

---


## Need Statement
Vehicular accidents are caused by people feeling too drowsy/tired.

## Goal Statement
Prevent people from driving while drowsy.

## Personas 
### 1. Truck Driver Persona   
* Name: Mike Dunford  
* Age: 42  
* Role: Long-haul truck driver  
* Experience: 15 years of commercial driving  
* Tech Comfort: Moderate  
* Primary Goal: Stay safe on long routes, avoid accidents, and keep his job performance strong.  
#### Background
Mike drives long interstate routes, often overnight or for extended hours. Fatigue, highway monotony, and pressure to meet delivery schedules are part of his daily routine.   He wants tools that help him stay alert, but he does not want to feel constantly punished or micromanaged.  
#### Needs  
* Real-time alerts when signs of drowsiness or distraction are detected    
* Alerts that are accurate and not overly sensitive    
* A system that helps prevent accidents before they happen    
* A simple mobile app that clearly explains what happened and what action to take    
* Confidence that the system is protecting him, not just monitoring him    
#### Pain Points  
* False alarms that go off when he is just checking mirrors or glancing at controls  
* Feeling like management is watching every move  
* Stress from long shifts and strict delivery deadlines  
* Concern that a single alert could be used unfairly against him  
#### Motivations  
* Wants to get home safely  
* Wants to maintain a good driving record  
* Wants proof that he is a responsible driver  
* Appreciates technology that supports him without being intrusive  
#### How He Uses the System  
* Camera monitors eye closure, head position, and attention level  
* Embedded AI system detects risky behavior such as microsleep, prolonged distraction, or head droop  
* Driver app sends immediate alerts like vibration, sound, or message prompts  
* He may receive suggestions such as “Take a break” or “Eyes on road”  
#### What Success Looks Like for Mike  
* Fewer fatigue-related incidents  
* Helpful alerts that feel like a safety assistant  
* Fair reporting to the fleet operator  
* Less risk of accidents, violations, and job-related stress  

### 2. Fleet Operator Persona  
* Name: Sarah Porter  
* Age: 38  
* Role: Fleet operations manager  
* Experience: 10 years in logistics and fleet safety  
* Tech Comfort: High  
* Primary Goal: Improve fleet safety, reduce liability, and keep operations efficient.  
#### Background  
Sarah oversees dozens or hundreds of vehicles and drivers. She is responsible for safety compliance, reducing accident   costs, minimizing downtime, and protecting the company’s reputation. She needs visibility into driver risk without manually reviewing every trip.  
#### Needs  
* Centralized dashboard or app notifications for serious safety events  
* Clear reporting on drowsiness, distraction, and repeated unsafe behavior  
* Actionable insights rather than raw video alone  
* Driver trend analysis over time  
* Evidence that helps with coaching, compliance, and insurance discussions  
#### Pain Points  
* Limited visibility into what happens on the road in real time  
* High cost of accidents, claims, and vehicle downtime  
* Difficulty identifying risky driver patterns before an incident occurs  
* Too many alerts can overwhelm operations teams  
* Need to balance driver privacy with company safety goals  
#### Motivations  
* Reduce accident frequency and severity  
* Protect drivers and company assets  
* Improve insurance outcomes and compliance posture  
* Coach drivers using objective data  
* Run a safer and more efficient fleet  
#### How She Uses the System  
* Receives app or dashboard alerts when risky driver behavior crosses a threshold  
* Reviews event summaries such as sleeping, head inattention, phone distraction, or repeated unsafe patterns  
* Uses reports to identify drivers who need coaching or schedule adjustments  
* Tracks safety trends across vehicles, routes, and shifts  
#### What Success Looks Like for Sarah  
* Fewer accidents and insurance claims  
* Better safety KPIs across the fleet  
* Faster intervention when a driver is at risk  
* Reliable data that supports training and accountability  
* A scalable system that does not require constant manual monitoring  

## Existing Technologies
Samsara is one of the clearest examples of the same system concept. Their dual-facing AI dash cam uses an inward-facing camera to analyze driver behavior in real time, including distracted driving detection, and their platform supports in-cab nudges plus alerts/workflows for managers. Their broader platform also ties camera events into driver apps, dashboards, reporting, and automation.

Seeing Machines Guardian is very close to our idea from the safety-monitoring angle. It continuously monitors fatigue and distraction, performs early drowsiness detection, tracks eye behavior for distraction analysis, and intervenes in real time before a microsleep or serious event occurs. 

Motive AI Dashcam is another strong existing design. Motive describes a layered architecture where unsafe behavior is detected on-device for immediate in-cab alerts, then validated and surfaced in the fleet dashboard for manager review. Their system also supports drowsiness-related detection and other unsafe behaviors.


## Sustainability Statement
This system contributes to sustainability by improving driver safety and reducing the likelihood of accidents caused by fatigue or distraction. Fewer accidents mean less vehicle damage, less material waste, lower repair costs, and less operational downtime. Because the system uses embedded AI on local hardware instead of relying entirely on cloud processing, it can also reduce communication overhead and improve energy efficiency. In addition, the system supports social sustainability by helping protect drivers, passengers, and the public through safer transportation practices.
