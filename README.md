
# CameraLib
- Support Image and Video Capture
- Support Zoom 
- Support Flash
- Support Most types Of Filters


![screen shot 2019-02-15 at 9 23 49 pm](https://user-images.githubusercontent.com/11280137/52880372-77571180-316a-11e9-9b7c-85f55086d821.png)


![screen shot 2019-02-15 at 9 48 57 pm](https://user-images.githubusercontent.com/11280137/52881922-c3a45080-316e-11e9-8065-94e998a27638.png)

using pods
```bash
pod 'CameraLib', '~> 1.2'
```

## Usage


```swift
   let cameraViewController = cameraEngine()

        cameraViewController.delegate = self

        cameraViewController.maximumVideoDurationLimit = 60

        cameraViewController.cameraPosition = .back

        cameraViewController.flashType = .on

        showCameraEngine(cameraEngineViewController: cameraViewController)
```


# you should implement Delegate 

```swift
extension ViewController: cameraEngineDelegate {

    func didSelect(originalImage: UIImage, filteredImage: UIImage) {        

    }

    func didSelect(videoUrl: URL) {   

    }
}

```
