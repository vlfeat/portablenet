//
//  BNorm.cpp
//  PortableNet
//
//  Created by dingding chen on 31/01/2018.
//  Copyright © 2018 VGG. All rights reserved.
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

ErrorCode BNorm(json const& opc, Workspace& ws) {
  auto op = vl::nn::BatchNorm(globalContext) ;
  try{
    if (opc.count("param")) {
      PNCHECK(op.setEpsilon(opc["param"].get<double>())) ;
    }
    
    // Get input data
    Tensor x = ws.get(opc["inputs"][0].get<string>()) ;
    Tensor mult = ws.get(opc["params"][0].get<string>()) ;
    Tensor bias = ws.get(opc["params"][1].get<string>()) ;
    Tensor moments = ws.get(opc["params"][2].get<string>()) ;
    
    // Call batch normalisation
    TensorShape yShape ;
    PNCHECK(op.forwardShape(yShape, moments, x)) ;
    char add =  opc["address"].get<char>();
    char * add2 = add + static_cast<char *>(ws.startAddress()) ;
    void * address = reinterpret_cast<void *>(add2) ;
    Tensor y = ws.assign(opc["outputs"][0].get<string>(),VLDT_Float,x.getShape(),address) ;
//    Tensor y = ws.get(opc["outputs"][0].get<string>(), VLDT_Float, yShape) ;
    
    PNCHECK(op.forwardWithMoment(y, moments, x, mult, bias)) ;
  }
  
  catch (json::exception& e) {
    auto msg = ostringstream()<<"Conv: JSON error: "<<e.what() ;
    return globalContext.setError(VLE_IllegalArgument, msg.str().c_str()) ;
  }
  return VLE_Success ;
}
