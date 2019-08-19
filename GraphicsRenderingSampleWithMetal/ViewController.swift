import UIKit
import MetalKit

final class ViewController: UIViewController {
    private var renderer: Renderer?

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let metalKitView = view as? MTKView else { return }

        metalKitView.enableSetNeedsDisplay = true
        metalKitView.device = MTLCreateSystemDefaultDevice()
        metalKitView.clearColor = MTLClearColorMake(0.0, 0.5, 1.0, 1.0)

        renderer = metalKitView.device.flatMap(Renderer.init)
        metalKitView.delegate = renderer
    }
}

private final class Renderer: NSObject, MTKViewDelegate {
    private let queue: MTLCommandQueue

    init?(device: MTLDevice) {
        guard let queue = device.makeCommandQueue() else { return nil }
        self.queue = queue
    }

    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        print("drawableSizeWillChange", size)
    }

    func draw(in view: MTKView) {
        guard
            let renderPassDescriptor = view.currentRenderPassDescriptor,
            let commandBuffer = queue.makeCommandBuffer(),
            let commandEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor),
            let drawable = view.currentDrawable else {
                return
        }

        commandEncoder.endEncoding()

        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
}

