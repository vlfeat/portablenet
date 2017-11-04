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
#include <sstream>
#include <memory>

#include "Program.hpp"
#include "mcn.hpp"
#include "json.hpp"

using namespace std ;
using namespace vl ;
using namespace nlohmann ;

ErrorCode Conv(json const& opc, Workspace& ws)
{
  auto op = vl::nn::Convolution(globalContext) ;
  try {
    if (opc.count("stride")) {
      PNCHECK(op.setStride(opc["stride"].get<vector<Int>>())) ;
    }
    if (opc.count("padding")) {
      PNCHECK(op.setPadding(opc["padding"].get<vector<Int>>())) ;
    }
    if (opc.count("dilation")) {
      PNCHECK(op.setDilation(opc["dilation"].get<vector<Int>>())) ;
    }

    // Get input data
    Tensor x = ws.get(opc["inputs"][0].get<string>()) ;
    Tensor w = ws.get(opc["params"][0].get<string>()) ;
    Tensor b = Tensor() ;
    if (opc["hasBias"].get<bool>()) {
      b = ws.get(opc["params"][1].get<string>()) ;
    }

    // Call convolution
    TensorShape yShape ;
    PNCHECK(op.forwardShape(yShape, x, w)) ;

    Tensor y = ws.get(opc["outputs"][0].get<string>(),VLDT_Float,yShape) ;
    PNCHECK(op.forward(y,0,x,1,w,b)) ;
  }
  catch (json::exception& e) {
    auto msg = ostringstream()<<"Conv: JSON error: "<<e.what() ;
    return globalContext.setError(VLE_IllegalArgument, msg.str().c_str()) ;
  }
  return VLE_Success ;
}
