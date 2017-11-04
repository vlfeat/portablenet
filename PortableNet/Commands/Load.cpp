//
//  Load.cpp
//  PortableNet
//
//  Created by Andrea Vedaldi on 16/10/2017.
//  Copyright © 2017 VGG. All rights reserved.
//

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

ErrorCode Load(json const& op, Workspace& ws)
{
  try {
    // Get the name of the output tensor.
    auto name = op["outputs"][0].get<string>() ;

    // Use tensor cached value if any.
    // Todo: this cannot be right in general.
    if (ws.exists(name)) { return VLE_Success ; }

    // Get the tensor data type.
    DataType dt ;
    if (op["dataType"] == "single") {
      dt = VLDT_Float ;
    } else if (op["dataType"] == "double") {
      dt = VLDT_Double ;
    } else {
      assert(false) ;
    }

    // Get the tensor dimensions.
    auto dims = op["shape"].get<vector<Int>>() ;
    TensorShape shape(dims);

    // Allocate the tensor in the workspace.
    auto tensor = ws.get(name, dt, shape) ;
    if (!shape.isEmpty() && tensor.isNull()) {
      // Allocation error.
      return VLE_OutOfMemory ;
    }

    // Read the tensor file.
    auto tensorPath = ws.baseName() + "/" + op["fileName"].get<string>() ;
    auto tensorFile = ifstream(tensorPath, ios::in | ios::binary) ;
    if (tensorFile.is_open()) {
      // Todo: endiannes conversion.
      tensorFile.read(reinterpret_cast<char*>(tensor.getMemory()),
                      shape.getNumElements() * getDataTypeSizeInBytes(dt)) ;
    }
  }
  catch (json::exception& e) {
    auto msg = ostringstream()<<"Load: JSON error: "<<e.what() ;
    return globalContext.setError(VLE_IllegalArgument, msg.str().c_str()) ;
  }
  return VLE_Success ;
}
