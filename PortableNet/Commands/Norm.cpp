//
//  LRN.cpp
//  PortableNet
//
//  Created by dingding chen on 31/12/2017.
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

ErrorCode Norm(json const& opc, Workspace& ws)
{
  auto op = vl::nn::LRN(globalContext) ;
  
  try{
    if (opc.count("param")) {
      PNCHECK(op.setParameters(opc["param"].get<vector<int>>()[0], opc["param"].get<vector<double>>()[1],opc["param"].get<vector<double>>()[2], opc["param"].get<vector<double>>()[3])) ;
    }
    
    // Get input data
    Tensor x = ws.get(opc["inputs"][0].get<string>()) ;
    
    // Call normalisation
    TensorShape yShape ;
    PNCHECK(op.forwardShape(yShape, x.getShape())) ;
    
    char add =  opc["address"].get<char>();
    char * add2 = add + static_cast<char *>(ws.startAddress()) ;
    void * address = reinterpret_cast<void *>(add2) ;
    Tensor y = ws.assign(opc["outputs"][0].get<string>(),VLDT_Float,yShape,address) ;
//    Tensor y = ws.get(opc["outputs"][0].get<string>(),VLDT_Float,yShape) ;
    PNCHECK(op.forward(y, x)) ;
    
//    ofstream resultFile;
//    resultFile.open("result", ios::out | ios::binary);
//    resultFile.write(static_cast<const char *>(y.getMemory()), yShape.getHeight()*yShape.getWidth()*yShape.getCardinality()*yShape.getNumChannels()*sizeof(float)) ;
//    resultFile.close();
    
  }catch (json::exception& e) {
    auto msg = ostringstream()<<"Conv: JSON error: "<<e.what() ;
    return globalContext.setError(VLE_IllegalArgument, msg.str().c_str()) ;
  }
  return VLE_Success ;
}
