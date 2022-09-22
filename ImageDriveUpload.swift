func uploadFileToDrive() {
        print("uploading Photo")
        let dateFormat  = NSDateFormatter()
        dateFormat.dateFormat = "'Quickstart Uploaded File ('EEEE MMMM d, YYYY h:mm a, zzz')"

        let file = GTLDriveFile()
        file.name = dateFormat.stringFromDate(NSDate())
        file.descriptionProperty = "Uploaded from Google Drive IOS"
        file.mimeType = "image/png"

        let fileManager = NSFileManager.defaultManager()
        let urls = fileManager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)

        // If array of path is empty the document folder not found
        guard urls.count == 0 else {
            let imageURL = urls.first!.URLByAppendingPathComponent("image.png")
            // Data object to fetch image data
            do {
                let imageData = try NSData(contentsOfURL: imageURL, options: NSDataReadingOptions())
                let uploadParameters = GTLUploadParameters(data: imageData, MIMEType: file.mimeType)
                let query = GTLQueryDrive.queryForFilesCreateWithObject(file, uploadParameters: uploadParameters) as GTLQueryDrive
                self.driveService.executeQuery(query, completionHandler:  { (ticket, insertedFile , error) -> Void in
                    let myFile = insertedFile as? GTLDriveFile

                    if error == nil {
                        print("File ID \(myFile?.identifier)")
                    } else {
                        print("An Error Occurred! \(error)")
                    }

                })
            } catch {
                print(error)
            }

            return
        }
   