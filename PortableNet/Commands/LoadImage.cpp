//
//  LoadImage.cpp
//  PortableNet
//
//  Created by Andrea Vedaldi on 18/10/2017.
//  Copyright © 2017 VGG. All rights reserved.
//

#include <stdio.h>

#include <iostream>
#include <fstream>
#include <sstream>
#include <memory>
#include <cstdlib>

#include "Program.hpp"
#include "mcn.hpp"
#include "json.hpp"

using namespace std ;
using namespace vl ;
using namespace nlohmann ;

ErrorCode LoadImage(json const& opc, Workspace& ws)
{
  try {
    // Get the name of the output tensor
    auto name = opc["outputs"][0].get<string>() ;

    // Get the input image requirement
    auto RequiredShape = opc["reshape"].get<vector<Int>>() ;
    ImageShape requiredShape(RequiredShape[0], RequiredShape[1], RequiredShape[2]) ;

    // Get average colour for data preprocessing
    // auto averageColor = opc["averageColor"].get<vector<float>>() ;
    
    // Read the shape of the input jpeg file
    const char * inputFilepointer = ws.inputName().c_str() ;
    ImageReader reader ;
    ImageShape imageShape;
    reader.readShape(imageShape, inputFilepointer) ;
    
    // Allocate sufficiently large buffer
    unique_ptr<float[]> buffer {new float [imageShape.height * imageShape.width * imageShape.depth]} ;
    // unique_ptr<float[]> temp {new float [imageShape.height * imageShape.width]} ;
    unique_ptr<float[]> out {new float [requiredShape.height * requiredShape.width * requiredShape.depth]} ;
    
    // Read the image
    reader.readPixels(buffer.get(), inputFilepointer) ;
    
    // Initialize input and output in the form of image
    Image input(imageShape, static_cast<float*>(buffer.get())) ;
    Image output(requiredShape, static_cast<float*>(out.get())) ;
      
      // Perform resize
    vl::impl::resizeImage(output, input) ;
    
    // Allocate the image in workspace
    TensorShape tensorShape(RequiredShape[0], RequiredShape[1], RequiredShape[2], 1);
    auto tensor = ws.get(name,VLDT_Float,tensorShape) ;
    
    Tensor tensorTemp(tensorShape, VLDT_Float, VLDT_CPU, static_cast<void *>(out.get()), tensorShape.getNumElements()*sizeof(float)) ;
    
    // Get average colour from workspace
    Tensor colour = ws.colour() ;

    // Preprocess by subtracting mean
    for (int k = 0; k < requiredShape.depth; k++) {
    for (int j = 0; j < requiredShape.height ; j++) {
      for (int i = 0; i < requiredShape.width ; i++) {
        static_cast<float *>(tensor.getMemory())[i + requiredShape.height * j + requiredShape.height * requiredShape.width * k] = static_cast<float *>(tensorTemp.getMemory())[i + requiredShape.width * j + requiredShape.height * requiredShape.width * k] - static_cast<float *>(colour.getMemory())[i + requiredShape.width * j + requiredShape.height * requiredShape.width * k];
      }
    }
    }
    
    ofstream resultFile;
    resultFile.open("image", ios::out | ios::binary);
    resultFile.write(static_cast<const char *>(tensor.getMemory()), 224*224*3*sizeof(float)) ;
    resultFile.close();

  } catch (json::exception& e) {
    auto msg = ostringstream()<<"LoadImage: JSON error: "<<e.what() ;
    return globalContext.setError(VLE_IllegalArgument, msg.str().c_str()) ;
  }

  // Todo: check the file was correctly read.
  return VLE_Success ;
}


