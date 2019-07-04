#include <string>
#include <vector>
#include <iostream>
#include <cpr/response.h>
#include <elasticlient/client.h>

int main(int argc, char* argv[])
{
  std::string username = std::string(argv[1]);
  std::string password = std::string(argv[2]);
  std::string address = std::string(argv[3]);
  std::string port = std::string(argv[4]);

  std::string index_name = std::string(argv[5]);
  
  std::string query_string = "http://" + username + ":" + password + "@" + address + ":" + port + "/";
  std::cout << "query string : " << query_string << std::endl;
  
  elasticlient::Client client({query_string}); // last / is mandatory

  std::cout << "index name : " << index_name << std::endl;
  cpr::Response retrievedDocument = client.search(index_name, "", "");
  std::cout << retrievedDocument.text << std::endl;

  return 0;
}
