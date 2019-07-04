include_directories(${CMAKE_CURRENT_SOURCE_DIR}
                    ${ELASTICLIENT_INCLUDE_DIRS})

add_executable(hello-world
               hello-world.cc)

add_executable(search
	       search.cc)
	       	     
target_link_libraries(hello-world
                      ${ELASTICLIENT_LIBRARIES})

target_link_libraries(search
		      ${ELASTICLIENT_LIBRARIES})
