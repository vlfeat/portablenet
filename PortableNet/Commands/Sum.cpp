//
//  Sum.cpp
//  PortableNet
//
//  Created by dingding chen on 31/01/2018.
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

ErrorCode Sum(json const& opc, Workspace& ws) {
  ErrorCode error = VLE_Success ;
  
  assert(opc["inputs"].is_array());
  assert(opc["outputs"].is_array());
  
  // The shape of output tensor should be the same as input tensor
  TensorShape yShape ;
  Tensor x1 = ws.get(opc["inputs"][0].get<string>()) ;
  yShape = x1.getShape() ;
  
  // Generate output tensor
  char add =  opc["address"].get<char>();
  char * add2 = add + static_cast<char *>(ws.startAddress()) ;
  void * address = reinterpret_cast<void *>(add2) ;
  Tensor y = ws.assign(opc["outputs"][0].get<string>(),VLDT_Float,yShape,address) ;
//  Tensor y = ws.get(opc["outputs"][0], VLDT_Float, yShape) ;
  
  // Initially output tensor is equal to the first input tensor
  for (int j = 0; j < y.getNumElements(); j++){
    static_cast<float *>(y.getMemory())[j] = static_cast<float *>(x1.getMemory())[j] ;
  }
  
  // Perform the rest of sum operation
  for (int i = 1; i < opc["inputs"].size(); i ++){
    Tensor x2 = ws.get(opc["inputs"][i].get<string>()) ;
    
    // Check if the dimentions are consistent
    assert(x1.getShape() == x2.getShape()) ;
    
    // Add the next tensor
    for (int j = 0; j < y.getNumElements(); j++){
      static_cast<float *>(y.getMemory())[j] += static_cast<float *>(x2.getMemory())[j] ;
      }
  }

  return error ;
}
