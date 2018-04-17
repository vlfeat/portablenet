//
//  DropOut.cpp
//  PortableNet
//
//  Created by dingding chen on 01/01/2018.
//  Copyright © 2018 VGG. All rights reserved.
//

#include <stdio.h>

#include <iostream>
#include <fstream>
#include <sstream>
#include <memory>

#include "Program.hpp"
#include "json.hpp"

using namespace std ;
using namespace vl ;
using namespace nlohmann ;

ErrorCode DropOut(json const& opc, Workspace& ws)
{
  ErrorCode error = VLE_Success ;
  
  // Initialize seed for random mask
  srand((unsigned)time(0)) ;
  
  assert(opc["inputs"].is_array()) ;
  assert(opc["outputs"].is_array()) ;
  
  // Get input data
  float rate = opc["rate"].get<float>() ;
  
  // Allocate the tensors in workspace
  Tensor x = ws.get(opc["inputs"][0].get<string>());
  char add =  opc["address"].get<char>();
  char * add2 = add + static_cast<char *>(ws.startAddress()) ;
  void * address = reinterpret_cast<void *>(add2) ;
  Tensor y = ws.assign(opc["outputs"][0].get<string>(),VLDT_Float,x.getShape(),address) ;
//  Tensor y = ws.get(opc["outputs"][0].get<string>(),VLDT_Float,x.getShape()) ;

  float scale = 1 / (1 - rate) ;
  
  // Creating a random mask
  for (int i = 0; i < y.getNumElements(); i++) {
    static_cast<float *>(y.getMemory())[i] = ((float)rand() / (float)RAND_MAX) * scale * static_cast<float *>(x.getMemory())[i] ;
  }
  
  return error ;
}
