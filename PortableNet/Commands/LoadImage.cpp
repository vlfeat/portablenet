//
//  LoadImage.cpp
//  PortableNet
//
//  Created by Andrea Vedaldi on 18/10/2017.
//  Copyright © 2017 VGG. All rights reserved.
//

#include <stdio.h>

#include <iostream>
#include <fstream>
#include <memory>
#include <cstdlib>

#include "Program.hpp"
#include "mcn.hpp"
#include "json.hpp"

using namespace std ;
using namespace vl ;
using namespace nlohmann ;

ErrorCode LoadImage(json const& opc, Workspace& ws)
{
  // Todo: error checking, gracefult exit, throw exceptions?
  assert(opc["outputs"].is_array()) ;

  // Get the name of the output tensor.
  auto name = opc["outputs"][0].get<string>() ;
  auto ts = TensorShape{224,224,3,1} ;
  auto t = ws.get(name,VLDT_Float,ts) ;
  generate(static_cast<float*>(t.getMemory()),
           static_cast<float*>(t.getMemory()) + t.getNumElements(),
           rand);

  // Todo: check the file was correctly read.
  return VLE_Success ;
}
