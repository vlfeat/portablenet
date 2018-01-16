//
//  Loss.cpp
//  PortableNet
//
//  Created by dingding chen on 03/01/2018.
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

ErrorCode SoftMax(json const& opc, Workspace& ws)
{
  ErrorCode error = VLE_Success;
  
  // Check if outputs and inputs are array
  assert(opc["inputs"].is_array());
  assert(opc["outputs"].is_array());
  
  // Read inputs and outputs from workspace
  Tensor x = ws.get(opc["inputs"][0].get<string>());
  Tensor y = ws.get(opc["outputs"][0].get<string>(),VLDT_Float,x.getShape()) ;
  
  // Error if x does not exist
  if (!x) { return VLE_IllegalArgument ; }
  
  // Allocate sufficiently large buffer
  unique_ptr<float[]> buffer {new float [x.getNumElements()]} ;
  
  // Initialise max and sum
  float sum = 0 ;
  float max = 0 ;
  
  // Find the max in inputs
  for (int j = 0; j < x.getNumElements(); j++){
    if (static_cast<float *>(x.getMemory())[j] > max){
      max = static_cast<float *>(x.getMemory())[j] ;
    }
  }
  
  // sum(exp(x[i] - max))
  for (int i = 0; i < x.getNumElements(); i++){
    static_cast<float *>(buffer.get())[i] = exp(static_cast<float *>(x.getMemory())[i] - max) ;
    sum += static_cast<float *>(buffer.get())[i] ;
  }
  
  for (int k = 0; k < x.getNumElements(); k++){
    static_cast<float *>(y.getMemory())[k] = static_cast<float *>(buffer.get())[k] / sum ;
  }

//    ofstream resultFile;
//    resultFile.open("result", ios::out | ios::binary);
//    resultFile.write(static_cast<const char *>(y.getMemory()), x.getHeight()*x.getWidth()*x.getCardinality()*x.getNumChannels()*sizeof(float)) ;
//    resultFile.close();
  
  return error;
}
