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
#include <sstream>
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
  try {
    // Get the name of the output tensor.
    auto name = opc["outputs"][0].get<string>() ;
    auto ts = TensorShape{224,224,3,1} ;
    auto t = ws.get(name,VLDT_Float,ts) ;
    // Todo: actually load an image.
    generate(static_cast<float*>(t.getMemory()),
             static_cast<float*>(t.getMemory()) + t.getNumElements(),
             rand);
  }
  catch (json::exception& e) {
    auto msg = ostringstream()<<"LoadImage: JSON error: "<<e.what() ;
    return globalContext.setError(VLE_IllegalArgument, msg.str().c_str()) ;
  }
  return VLE_Success ;
}
