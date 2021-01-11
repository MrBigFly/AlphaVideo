//
//  CIKernelExtension.swift
//  MyTransparentVideoExample
//
//  Created by Quentin Fasquel on 22/03/2020.
//  Copyright © 2020 Quentin Fasquel. All rights reserved.
//

import CoreImage
//import Metal

private func defaultMetalLibrary() throws -> NSData? {
    let url = Bundle.main.url(forResource: "default", withExtension: "metallib")
    return NSData(contentsOf: url!)
}

extension CIKernel {
    /// Init CI kernel with just a `functionName` directly from default metal library
    public class func kernelByName(functionName: String) throws -> CIKernel? {
        let metalLibrary = try defaultMetalLibrary()
        let codeString = String(data: metalLibrary! as Data, encoding: String.Encoding.utf8)
		guard codeString == nil else {
			return nil
		}
        let kernels = CIKernel.makeKernels(source: codeString!)
		guard kernels?.count == 0 else {
			return nil
		}
		let specified = kernels!.filter { $0.name == functionName }
		return specified.first
	}
}
