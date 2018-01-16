//
//  ReLU.cpp
//  PortableNet
//
//  Created by dingding chen on 09/11/2017.
//  Copyright © 2017 VGG. All rights reserved.
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

ErrorCode ReLU(json const& opc, Workspace& ws)
{
  ErrorCode error = VLE_Success;
  
  assert(opc["inputs"].is_array());
  assert(opc["outputs"].is_array());
  
  Tensor x = ws.get(opc["inputs"][0].get<string>());
  Tensor y = ws.get(opc["outputs"][0].get<string>(),VLDT_Float,x.getShape()) ;
  
  if (!x) { return VLE_IllegalArgument ; }
  
  void* Xmemory = x.getMemory();
  float* XmemoryFloat = static_cast<float*>(Xmemory);
  void* Ymemory = y.getMemory();
  float* YmemoryFloat = static_cast<float*>(Ymemory);
  
  assert(x.getDataType() == VLDT_Float);
  
  for (int i = 0; i < x.getNumElements(); i++)
  {
   if(XmemoryFloat[i] < 0)
   {
     YmemoryFloat[i] = 0;
   }
    else
    {
     YmemoryFloat[i] = XmemoryFloat[i];
    }
  }
//  ofstream resultFile;
//  resultFile.open("result", ios::out | ios::binary);
//  resultFile.write(static_cast<const char *>(y.getMemory()), x.getHeight()*x.getWidth()*x.getCardinality()*x.getNumChannels()*sizeof(float)) ;
//  resultFile.close();
  
  return error;
}

