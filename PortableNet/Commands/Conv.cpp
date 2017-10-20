//
//  Conv.cpp
//  PortableNet
//
//  Created by Andrea Vedaldi on 16/10/2017.
//  Copyright © 2017 VGG. All rights reserved.
//

#include <stdio.h>

#include <iostream>
#include <fstream>
#include <memory>

#include "Program.hpp"
#include "mcn.hpp"
#include "json.hpp"

using namespace std ;
using namespace vl ;
using namespace nlohmann ;

ErrorCode Conv(json const& opc, Workspace& ws)
{
  ErrorCode error = VLE_Success ;
  // Todo: error checking, gracefult exit, throw exceptions?
  assert(opc["inputs"].is_array()) ;
  assert(opc["outputs"].is_array()) ;
  assert(opc["params"].is_array()) ;

  auto op = vl::nn::Convolution(globalContext) ;

  if (opc.count("stride")) {
    op.setStride(opc["stride"].get<vector<Int>>()) ;    
  }

  if (opc.count("padding")) {
    op.setPadding(opc["padding"].get<vector<Int>>()) ;
  }

  if (opc.count("dilation")) {
    op.setDilation(opc["dilation"].get<vector<Int>>()) ;
  }

  // Get input data
  Tensor x = ws.get(opc["inputs"][0].get<string>()) ;
  Tensor w = ws.get(opc["params"][0].get<string>()) ;
  Tensor b = Tensor() ;
  if (!areCompatible(x,w)) {
    assert(false) ;
  }
  if (opc["hasBias"].get<bool>()) {
    b = ws.get(opc["params"][1].get<string>()) ;
    if (!areCompatible(x,b)) {
      assert(false) ;
    }
  }
  if (!x) { return VLE_IllegalArgument ; }

  // Call convolution
  TensorShape yShape ;
  error = op.forwardShape(yShape, x, w) ;
  Tensor y = ws.get(opc["outputs"][0].get<string>(),VLDT_Float,yShape) ;

  error = op.forward(y,0,x,1,w,b) ;
  return error ;
}
