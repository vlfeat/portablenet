//
//  Release.cpp
//  PortableNet
//
//  Created by dingding chen on 01/02/2018.
//  Copyright © 2018 VGG. All rights reserved.
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

ErrorCode Release(json const& opc, Workspace& ws){
  ErrorCode error = VLE_Success ;
  
  // For multiple inputs
  for (int i = 0; i < opc["name"].size(); i++) {
    auto name = opc["name"].get<string>() ;
    
    // Check that this input exists
    bool flag = ws.exists(name) ;
    assert(flag) ;
    
    // Call release option
    ws.remove(name) ;
    
  }
  
  return error;
}
