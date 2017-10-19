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

class Program ;
class Workspace ;

extern vl::Context globalContext ;

vl::ErrorCode Load(nlohmann::json const& op, Workspace& ws) ;
vl::ErrorCode LoadImage(nlohmann::json const& op, Workspace& ws) ;
vl::ErrorCode Conv(nlohmann::json const& op, Workspace& ws) ;

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
  void baseName(std::string const& name) ;

private:
  std::string baseNameString ;
  std::map<std::string,vl::Tensor> tensors ;
} ;

class Program
{
public:
  void load(std::string fileName) ;
  void print() const ;
  void execute(Workspace& ws) ;
  nlohmann::json const& getSource() const ;

private:
  nlohmann::json source ;

  // List of tensor parameters and corresponding data blobs.
  std::vector<vl::Tensor> params ;
  std::vector<std::unique_ptr<float[]>> paramBlobs ;
} ;

#endif /* network_hpp */
