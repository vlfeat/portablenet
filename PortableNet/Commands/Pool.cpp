//
//  Pooling.cpp
//  PortableNet
//
//  Created by dingding chen on 06/11/2017.
//  Copyright © 2017 VGG. All rights reserved.
//

#include <stdio.h>

#include <iostream>
#include <fstream>
#include <memory>

#include "Program.hpp"
#include "json.hpp"
#include "mcn.hpp"

using namespace std;
using namespace vl;
using namespace nlohmann;

ErrorCode Pool(json const& opc, Workspace& ws)
{
  ErrorCode error = VLE_Success;
  assert(opc["inputs"].is_array());
  assert(opc["outputs"].is_array());
  assert(opc["params"].is_array());
  
  auto op = vl::nn::Pooling(globalContext);
  
  if (opc.count("padding")) {
    op.setPadding(opc["padding"].get<vector<Int>>());
  }
  
  if (opc.count("stride")) {
    op.setStride(opc["stride"].get<vector<Int>>());
  }
  
  // Get input data
  Tensor x = ws.get(opc["inputs"][0].get<string>()) ;
  
  if (!x) {return VLE_IllegalArgument;}
  
  // Call pooling
  TensorShape yShape;
  error = op.forwardShape(yShape, x);
  Tensor y = ws.get(opc["outputs"][0].get<string>(), VLDT_Float, yShape);
  
  error = op.forward(y, x);
  
  return error;
}

