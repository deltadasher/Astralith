cmake_minimum_required(VERSION 3.19)

project(astralith-caelestia-blobs LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

find_package(Qt6 6.9 REQUIRED COMPONENTS Core Qml Quick ShaderTools)
qt_standard_project_setup(REQUIRES 6.9)

if(NOT DEFINED CAELESTIA_SOURCE_DIR)
    message(FATAL_ERROR "CAELESTIA_SOURCE_DIR must point to a Caelestia Shell checkout")
endif()

if(NOT DEFINED ASTRALITH_QML_OUTPUT_DIR)
    set(ASTRALITH_QML_OUTPUT_DIR "${CMAKE_BINARY_DIR}/qml")
endif()

set(QT_QML_OUTPUT_DIRECTORY "${ASTRALITH_QML_OUTPUT_DIR}")
set(BLOB_DIR "${CAELESTIA_SOURCE_DIR}/plugin/src/Caelestia/Blobs")

foreach(required_file
        blobgroup.cpp blobgroup.hpp
        blobshape.cpp blobshape.hpp
        blobrect.cpp blobrect.hpp
        blobinvertedrect.cpp blobinvertedrect.hpp
        blobmaterial.cpp blobmaterial.hpp
        shaders/blob.frag shaders/blob.vert)
    if(NOT EXISTS "${BLOB_DIR}/${required_file}")
        message(FATAL_ERROR "Missing Caelestia blob source: ${BLOB_DIR}/${required_file}")
    endif()
endforeach()

qt_add_qml_module(caelestia-blobs
    URI Caelestia.Blobs
    SOURCES
        "${BLOB_DIR}/blobgroup.cpp"
        "${BLOB_DIR}/blobgroup.hpp"
        "${BLOB_DIR}/blobshape.cpp"
        "${BLOB_DIR}/blobshape.hpp"
        "${BLOB_DIR}/blobrect.cpp"
        "${BLOB_DIR}/blobrect.hpp"
        "${BLOB_DIR}/blobinvertedrect.cpp"
        "${BLOB_DIR}/blobinvertedrect.hpp"
        "${BLOB_DIR}/blobmaterial.cpp"
        "${BLOB_DIR}/blobmaterial.hpp"
)

target_include_directories(caelestia-blobs PRIVATE "${BLOB_DIR}")
target_link_libraries(caelestia-blobs PRIVATE Qt6::Core Qt6::Qml Qt6::Quick)

set(blob_fragment "${BLOB_DIR}/shaders/blob.frag")
set(blob_vertex "${BLOB_DIR}/shaders/blob.vert")

qt_add_shaders(caelestia-blobs "blob_shaders"
    BATCHABLE OPTIMIZED NOHLSL NOMSL
    GLSL "300es,330"
    PREFIX "/"
    BASE "${BLOB_DIR}"
    FILES "${blob_fragment}" "${blob_vertex}"
)

# Keep the backing library beside the generated QML plugin.  This makes the
# optional runtime relocatable instead of baking the machine's build directory
# into the plugin RUNPATH.
set(blob_module_dir "${ASTRALITH_QML_OUTPUT_DIR}/Caelestia/Blobs")
set_target_properties(caelestia-blobs PROPERTIES
    LIBRARY_OUTPUT_DIRECTORY "${blob_module_dir}"
)
set_target_properties(caelestia-blobsplugin PROPERTIES
    BUILD_RPATH "$ORIGIN"
    INSTALL_RPATH "$ORIGIN"
)
