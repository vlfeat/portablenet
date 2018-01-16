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
#include <sstream>
#include <memory>

#include "Program.hpp"
#include "json.hpp"
#include "mcn.hpp"

using namespace std;
using namespace vl;
using namespace nlohmann;

ErrorCode Pool(json const& opc, Workspace& ws)
{
  auto op = vl::nn::Pooling(globalContext);
  
  try {
  
  if (opc.count("padding")) {
    PNCHECK(op.setPadding(opc["padding"].get<vector<Int>>()));
  }
  
  if (opc.count("stride")) {
    PNCHECK(op.setStride(opc["stride"].get<vector<Int>>()));
  }
    
  if (opc.count("shape")) {
      PNCHECK(op.setShape(opc["shape"].get<vector<Int>>()));
  }
  
  // Get input data
  Tensor x = ws.get(opc["inputs"][0].get<string>()) ;
  
  if (!x) {return VLE_IllegalArgument;}
  
  // Call pooling
  TensorShape yShape;
  PNCHECK(op.forwardShape(yShape, x));
  
  Tensor y = ws.get(opc["outputs"][0].get<string>(), VLDT_Float, yShape);
  PNCHECK(op.forward(y, x));
  
//    ofstream resultFile;
//    resultFile.open("result", ios::out | ios::binary);
//    resultFile.write(static_cast<const char *>(y.getMemory()), yShape.getHeight()*yShape.getWidth()*yShape.getCardinality()*yShape.getNumChannels()*sizeof(float)) ;
//    resultFile.close();
    
}
  catch (json::exception& e) {
    auto msg = ostringstream()<<"Conv: JSON error: "<<e.what() ;
    return globalContext.setError(VLE_IllegalArgument, msg.str().c_str()) ;
  }
  return VLE_Success ;
}

