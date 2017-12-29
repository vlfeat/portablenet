//
//  network.hpp
//  PortableNet
//
//  Created by Andrea Vedaldi on 15/10/2017.
//  Copyright © 2017 VGG. All rights reserved.
//

#ifndef network_hpp
#define network_hpp

#include "mcn.hpp"
#include "json.hpp"
#include <map>

#define PNCHECK(x) \
{ auto error = (x) ; if (error != vl::VLE_Success) { \
return globalContext.passError(error,__func__) ; } }

class Program ;
class Workspace ;

extern vl::Context globalContext ;

vl::ErrorCode Load(nlohmann::json const& op, Workspace& ws) ;
vl::ErrorCode LoadImage(nlohmann::json const& op, Workspace& ws) ;
vl::ErrorCode Conv(nlohmann::json const& op, Workspace& ws) ;
vl::ErrorCode Pool(nlohmann::json const& op, Workspace& ws);
vl::ErrorCode ReLU(nlohmann::json const& op, Workspace& ws);

class Workspace
{
public:
  ~Workspace() ;
  void print() const ;
  bool exists(std::string name) const ;
  vl::Tensor get(std::string name) ;
  vl::Tensor get(std::string name, vl::DataType dt, vl::TensorShape const& shape) ;
  void remove(std::string name) ;
  std::string const& baseName() const ;
  std::string const& inputName() const ;
  int const& printmethod() const ;
  void baseName(std::string const& name) ;
  void inputName(std::string const& inputFile) ;
  void printMethod(int const& printMethod) ;
 
private:
  std::string baseNameString;
  std::string inputFileName;
  int method;
  std::map<std::string,vl::Tensor> tensors ;
} ;

class Program
{
public:
  void load(std::string fileName) ;
  void print() const ;
  vl::ErrorCode execute(Workspace& ws) ;
  nlohmann::json const& getSource() const ;

private:
  nlohmann::json source ;
} ;

#endif /* network_hpp */
