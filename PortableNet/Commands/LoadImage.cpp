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

unsigned char test_image[784]= {
  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  3, 18, 18, 18,126,136,175, 26,166,255,247,127,  0,  0,  0,  0,
  0,  0,  0,  0,  0,  0,  0,  0, 30, 36, 94,154,170,253,253,253,253,253,225,172,253,242,195, 64,  0,  0,  0,  0,
  0,  0,  0,  0,  0,  0,  0, 49,238,253,253,253,253,253,253,253,253,251, 93, 82, 82, 56, 39,  0,  0,  0,  0,  0,
  0,  0,  0,  0,  0,  0,  0, 18,219,253,253,253,253,253,198,182,247,241,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
  0,  0,  0,  0,  0,  0,  0,  0, 80,156,107,253,253,205, 11,  0, 43,154,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
  0,  0,  0,  0,  0,  0,  0,  0,  0, 14,  1,154,253, 90,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,139,253,190,  2,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0, 11,190,253, 70,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0, 35,241,225,160,108,  1,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0, 81,240,253,253,119, 25,  0,  0,  0,  0,  0,  0,  0,  0,  0,
  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0, 45,186,253,253,150, 27,  0,  0,  0,  0,  0,  0,  0,  0,
  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0, 16, 93,252,253,187,  0,  0,  0,  0,  0,  0,  0,  0,
  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,249,253,249, 64,  0,  0,  0,  0,  0,  0,  0,
  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0, 46,130,183,253,253,207,  2,  0,  0,  0,  0,  0,  0,  0,
  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0, 39,148,229,253,253,253,250,182,  0,  0,  0,  0,  0,  0,  0,  0,
  0,  0,  0,  0,  0,  0,  0,  0,  0,  0, 24,114,221,253,253,253,253,201, 78,  0,  0,  0,  0,  0,  0,  0,  0,  0,
  0,  0,  0,  0,  0,  0,  0,  0, 23, 66,213,253,253,253,253,198, 81,  2,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
  0,  0,  0,  0,  0,  0, 18,171,219,253,253,253,253,195, 80,  9,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
  0,  0,  0,  0, 55,172,226,253,253,253,253,244,133, 11,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
  0,  0,  0,  0,136,253,253,253,212,135,132, 16,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0
};


ErrorCode LoadImage(json const& opc, Workspace& ws)
{
  try {
    auto name = opc["outputs"][0].get<string>() ;
    auto resizedShape = opc["resize"][0].get<vector<Int>>() ;

    auto ts = TensorShape{28,28,1,1} ;
    auto t = ws.get(name,VLDT_Float,ts) ;
    assert(t.getNumElements() == sizeof(test_image)) ;

    float* td = static_cast<float*>(t.getMemory());
    for (int j = 0; j < 28 ; ++j) {
      for (int i = 0; i < 28 ; ++i) {
        td[i + 28*j] = float(test_image[j + 28*i]) - 33.3185f;
      }
    }
  } catch (json::exception& e) {
    auto msg = ostringstream()<<"LoadImage: JSON error: "<<e.what() ;
    return globalContext.setError(VLE_IllegalArgument, msg.str().c_str()) ;
  }

  // Todo: check the file was correctly read.
  return VLE_Success ;
}

//}
//
//  try {
//    // Get the name of the output tensor.
//    auto name = opc["outputs"][0].get<string>() ;
//    auto ts = TensorShape{224,224,3,1} ;
//    auto t = ws.get(name,VLDT_Float,ts) ;
//    // Todo: actually load an image.
//    generate(static_cast<float*>(t.getMemory()),
//             static_cast<float*>(t.getMemory()) + t.getNumElements(),
//             rand);
//  }
//  catch (json::exception& e) {
//    auto msg = ostringstream()<<"LoadImage: JSON error: "<<e.what() ;
//    return globalContext.setError(VLE_IllegalArgument, msg.str().c_str()) ;
//  }
//
//  // Todo: error checking, gracefult exit, throw exceptions?
//  assert(opc["outputs"].is_array()) ;
//
//  // Get the name of the output tensor.
//  auto name = opc["outputs"][0].get<string>() ;
//  auto ts = TensorShape{28,28,1,1} ;
//  auto t = ws.get(name,VLDT_Float,ts) ;
//  generate(static_cast<float*>(t.getMemory()),
//           static_cast<float*>(t.getMemory()) + t.getNumElements(),
//           rand);
//
//  assert(t.getNumElements() == sizeof(test_image)) ;
//
//  float* td = static_cast<float*>(t.getMemory());
//  for (int i = 0; i < t.getNumElements(); i++)
//  {
//    td[i] = float(test_image[i]) - 33.3185f;
//  }
//
//  // Todo: check the file was correctly read.
//  return VLE_Success ;
//}
//

