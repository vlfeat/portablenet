//
//  LoadAverageColour.cpp
//  PortableNet
//
//  Created by dingding chen on 04/01/2018.
//  Copyright © 2018 VGG. All rights reserved.
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

ErrorCode LoadMeta(Workspace& ws){
  try{
    DataType dt = VLDT_Float ;
    
    // The dimension of average colour is the same as input requirement
    const std::vector<Int> dims = {224, 224, 3, 1} ;
    TensorShape shape(dims);
    
    // Store the average colour tensor in workspace
    auto tensor = ws.getAverageColour(dt, shape) ;

    // Read the tensor file.
    auto tensorPath = ws.baseName() + "/" + "averageColour.tensor" ;
    auto tensorFile = ifstream(tensorPath, ios::in | ios::binary) ;
    if (tensorFile.is_open()) {
      // Todo: endiannes conversion.
      tensorFile.read(reinterpret_cast<char*>(tensor.getMemory()),
                      shape.getNumElements() * getDataTypeSizeInBytes(dt)) ;
    }
 
    // Read the text file describing description of classes as a stream
    auto FileName = ws.baseName() + "/description.txt" ;
    ifstream File(FileName) ;
    std::stringstream buffer ;
    buffer << File.rdbuf() ;
    std::string test = buffer.str() ;
    
    // Parse the text file using "cursors"
    size_t pos1 = 0 ;
    size_t pos2 ;
    
    for (int i = 0; i < 1000; i++){
    pos2 = test.find("|", pos1) ;
    ws.getDescription(i, test.substr(pos1, (pos2 - pos1))) ;
    pos1 = pos2 + 1 ;
    
    }
    
  }catch (json::exception& e) {
    auto msg = ostringstream()<<"Load: JSON error: "<<e.what() ;
    return globalContext.setError(VLE_IllegalArgument, msg.str().c_str()) ;
  }
  return VLE_Success ;
}
