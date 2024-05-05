-	Intelligence report provided by trusted informant.
-	Contacted supervisor of Case B4DM755, William S. McLean
-	Suspect thought to be in Metro Manilla, Philippines.
-	Transaction to happen today with known gang members.
-	Location would be incriminating to the informant.
-	The court issued a search warrant for our DFIR investigation.
- law enforcement arrived late at the suspects residence where transaction took place
- found a flash drive under the desk
- the intials WSM were attached to a key chain containing the drive
- 
## Important roles for dfir investigation
-	Forensic Lab Analyst
-	DFIR First Responder
## Forensic Acquisition Process
-	Take image of RAM
-	Check for drive encryption
-	Take image of drive
## Chain of custody
-	Ensure proper documentation
-	Hash and copy
-	Do not perform appropriate shutdown, pull plug instead so as not to trigger anti-forensics possibly
- Bag Tag and Seal artefacts before sending to lab
- Field Operative and Forensic Lab Analyst fill out chain of custody forms
## using FTK imager
- enable write blocking on the image
  ```bash
  mount -o ro /dev/sda1 /mnt/sda1/
  ```
  ```bash
  # blockdev sets the block device to read only so remount after setting this attribute
  blockdev --setro /dev/sdb
  ```
  - in a real investigation a hardware write blocker may be used
### FTK UI
![image](https://github.com/Coastline-XploitClub/CCDC/assets/85032657/ac5b9d57-163f-4925-9954-98c20a009458)
- Verify encryption, obtain disk image, and analyze
  - Detecting encryption with FTK imager
    - Add evidence item
    - Choose physical drive
    - select attached drive
    - select "Detect EFS Encryption" (Windows specific)
    - report whether drive was encrypted or not
      ![image](https://github.com/Coastline-XploitClub/CCDC/assets/85032657/c1d98d64-1b12-4d6c-a7ed-4c076971f66a)
        ### creating disk image with FTK
      - select verify images after they are created and **create directory of all files on the image**
      ![image](https://github.com/Coastline-XploitClub/CCDC/assets/85032657/3596ebe6-8d62-456a-99cf-23989bb66749)
      ![image](https://github.com/Coastline-XploitClub/CCDC/assets/85032657/ac5932f8-9145-4191-b0a7-a6870b9f7732)

      - when you select "verify..." it hash the forensic disk image and physical drive
      - document hashes
        ![image](https://github.com/Coastline-XploitClub/CCDC/assets/85032657/f4ce4876-c6a2-42f0-ac9b-b0fa447901c8)

        ### mount image
        - add evidence item
        - add image file (we are using dd here)
          - look for signs of deleted files, corrupted files (size 0), and **obfuscation** conflicting header and file type
          - hit export files in a directory to save hidden/non hidden files
    ## continued examination steps
    - verify and document chain of custody
    - create forensic disk image
    - make cryptographic hashes (SHA1) and document process and hashes
    - Preserve the evidence
    - Perform analysis making sure not to tamper with evidence
    - Document all examination operations
    - in court presentation verify all hashes match (forensic disk image and hard drive)

    ## court proceedings
    - **Pre search**: send a request to preserve all data logs of social media accounts
    - Send a request to preserve data and log to supsect ISP
    - warrant for search seizure and examination
    - perform an inspection of public social media profiles
    - **Search**: by warrant obtain social media and ISP data
    - perform search and seizure of computer data
      
    - **Post Search**: perform forensic analysis on artefacts and evidence
    - **Trial** present forensic evidence and artefacts together with proper documentation
    - 
