//
//  Load.cpp
//  PortableNet
//
//  Created by Andrea Vedaldi on 16/10/2017.
//  Copyright © 2017 VGG. All rights reserved.
//

#include <iostream>
#include <fstream>
#include <memory>

#include "Program.hpp"
#include "mcn.hpp"
#include "json.hpp"

using namespace std ;
using namespace vl ;
using namespace nlohmann ;

ErrorCode Load(json const& op, Workspace& ws)
{
  // Todo: error checking, gracefult exit, throw exceptions?
  assert(op["inputs"].is_array()) ;
  assert(op["outputs"].is_array()) ;
  assert(op["fileName"].is_string()) ;
  assert(op["dataType"].is_string()) ;
  assert(op["shape"].is_array()) ;

  // Get the name of the output tensor.
  auto name = op["outputs"][0].get<string>() ;

  // Use tensor cached value if any.
  // Todo: this cannot be right in general.
  if (ws.exists(name)) { return VLE_IllegalArgument ; }

  // Get the tensor data type.
  DataType dt ;
  if (op["dataType"] == "single") {
    dt = VLDT_Float ;
  } else if (op["dataType"] == "double") {
    dt = VLDT_Double ;
  } else {
    assert(false) ;
  }

  // Get the tensro dimensions.
  auto dims = op["shape"].get<vector<size_t>>() ;
  TensorShape shape(dims);

  // Allocate the tensor in the workspace.
  auto tensor = ws.get(name, dt, shape) ;

  // Read the tensor file.
  auto tensorPath = ws.baseName() + "/" + op["fileName"].get<string>() ;
  auto tensorFile = ifstream(tensorPath, ios::in | ios::binary) ;
  if (tensorFile.is_open()) {
    // Todo: endian.
    tensorFile.read(reinterpret_cast<char*>(tensor.getMemory()),
                    shape.getNumElements() * getDataTypeSizeInBytes(dt)) ;
  }
  // Todo: check the file was correctly read.
  return VLE_Success ;
}
