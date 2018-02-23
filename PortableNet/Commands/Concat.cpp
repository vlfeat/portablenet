//
//  Concat.cpp
//  PortableNet
//
//  Created by dingding chen on 02/02/2018.
//  Copyright © 2018 VGG. All rights reserved.
//

#include <stdio.h>

#include <iostream>
#include <fstream>
#include <memory>

#include "Program.hpp"
#include "json.hpp"

using namespace std;
using namespace vl;
using namespace nlohmann;

vl::ErrorCode Concat(json const& opc, Workspace& ws) {

  ErrorCode error = VLE_Success ;
  
  assert(opc["inputs"].is_array());
  assert(opc["outputs"].is_array());
  
  // Get input data
  int dims = opc["dimension"].get<int>() ;
  assert(dims == 3) ;
  int dim = dims - 1 ;
  
  // Get size of output
  TensorShape yShape ;
  
  // Initialize the shape of y as the shape of x
  Tensor x0= ws.get(opc["inputs"][0].get<string>()) ;
  yShape.setWidth(x0.getWidth()) ;
  yShape.setHeight(x0.getHeight()) ;
  yShape.setSize(x0.getCardinality()) ;
  
  // The number of inputs
  Int inputSize = opc["inputs"].size() ;
  
  // Record the depth of each input tensor
  Int xDim[inputSize] ;
  Int xDimCounter = 0 ;
  
  Int yCounter = 0 ;
  
  
  // Change output shape as of concatenation
  for (int i = 0; i < inputSize; i ++){
    
    Tensor x = ws.get(opc["inputs"][i].get<string>()) ;
    xDim[i] = x.getDimension(dim) ;
    xDimCounter = xDimCounter + xDim[i] ;
  }
  
  yShape.setDepth(xDimCounter) ;
  
  // Allocate space for output
  Tensor y = ws.get(opc["outputs"][0], VLDT_Float, yShape) ;
  
  // Perform concatenation
  for (int u = 0; u < inputSize; u++){
    Tensor x = ws.get(opc["inputs"][u].get<string>()) ;
    assert(x.getCardinality() == 1);
  for (int i = 0; i < x.getHeight() * x.getWidth() * x.getNumChannels(); i++) {
  static_cast<float *>(y.getMemory())[yCounter] = static_cast<float *>(x.getMemory())[i] ;
    yCounter++ ;
  }
  }
  
  
  return error ;

}
