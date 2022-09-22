import UIKit
import AWSS3
import AWSCognito

func uploadS3(image: UIImage,
              name: String,
              progressHandler: @escaping (Progress) -> Void,
              completionHandler: @escaping (Error?) -> Void) {

    guard let data = UIImageJPEGRepresentation(image, Constants.uploadImageQuality) else {
        DispatchQueue.main.async {
            completionHandler(NetErrors.imageFormatError) // Replace your error
        }
        return
    }

    let credentialsProvider = AWSStaticCredentialsProvider(accessKey: Constants.accessKeyS3, secretKey: Constants.secretKeyS3)
    let configuration = AWSServiceConfiguration(region: Constants.regionS3, credentialsProvider: credentialsProvider)
    AWSServiceManager.default().defaultServiceConfiguration = configuration
    let expression = AWSS3TransferUtilityUploadExpression()
    expression.progressBlock = { task, progress in
        DispatchQueue.main.async {
            progressHandler(progress)
        }
    }

    AWSS3TransferUtility.default().uploadData(
        data,
        bucket: Constants.bucketS3,
        key: name,
        contentType: "image/jpg",
        expression: expression) { task, error in
            DispatchQueue.main.async {
                completionHandler(error)
            }
            print("Success")

        }.continueWith { task -> AnyObject? in
            if let error = task.error {
                DispatchQueue.main.async {
                    completionHandler(error)
                }
            }
            return nil
    }
}