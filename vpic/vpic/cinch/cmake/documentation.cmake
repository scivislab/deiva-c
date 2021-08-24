#------------------------------------------------------------------------------#
# Copyright (c) 2014 Los Alamos National Security, LLC
# All rights reserved.
#------------------------------------------------------------------------------#

#
# cinch_add_doc
#

include(CMakeParseArguments)

function(cinch_add_doc target config directory output)

    #--------------------------------------------------------------------------#
    # Setup optional arguments
    #--------------------------------------------------------------------------#

    set(options)
    set(one_value_args)
    set(multi_value_args PANDOC_OPTIONS IMAGE_GLOB)
    cmake_parse_arguments(extra "${options}" "${one_value_args}"
        "${multi_value_args}" ${ARGN})

    #--------------------------------------------------------------------------#
    # Add option to enable documentation
    #--------------------------------------------------------------------------#

    option(ENABLE_DOCUMENTATION "Enable documentation" OFF)
    option(ENABLE_CINCH_VERBOSE "Enable cinch verbose output" OFF)
    option(ENABLE_CINCH_DEVELOPMENT "Enable cinch development output" OFF)

    if(ENABLE_DOCUMENTATION)

        #----------------------------------------------------------------------#
        # Find the cinch command-line tool
        #----------------------------------------------------------------------#

        find_package(Cinch)

        if(NOT CINCH_FOUND)
            # FIXME: Try to build and install cinch

            message(FATAL_ERROR
                "The cinch command-line tool is needed to enable this option")
        endif(NOT CINCH_FOUND)

        set(CINCH_VERBOSE "")

        if(ENABLE_CINCH_VERBOSE)
            message(STATUS "enabling verbose cinch output")
            set(CINCH_VERBOSE "-v")
        endif(ENABLE_CINCH_VERBOSE)

        set(CINCH_DEVELOPMENT "")

        if(ENABLE_CINCH_DEVELOPMENT)
            message(STATUS "enabling development cinch output")
            set(CINCH_DEVELOPMENT "-d")
        endif(ENABLE_CINCH_DEVELOPMENT)

        #----------------------------------------------------------------------#
        # Find pandoc
        #----------------------------------------------------------------------#

        find_package(Pandoc)

        if(NOT PANDOC_FOUND)
            message(FATAL_ERROR
                "Pandoc is needed to enable this option")
        endif(NOT PANDOC_FOUND)

        #----------------------------------------------------------------------#
        # Create the target directory if it doesn't exist.  This is where the
        # documentation target will be written.
        #----------------------------------------------------------------------#

        if(NOT EXISTS ${CMAKE_BINARY_DIR}/doc)
            file(MAKE_DIRECTORY ${CMAKE_BINARY_DIR}/doc)
        endif(NOT EXISTS ${CMAKE_BINARY_DIR}/doc)

        #----------------------------------------------------------------------#
        # Create the target build directory if it doesn't exist.  This is
        # where the intermediate files will be written.
        #----------------------------------------------------------------------#

        if(NOT EXISTS ${CMAKE_BINARY_DIR}/doc/.${target})
            file(MAKE_DIRECTORY ${CMAKE_BINARY_DIR}/doc/.${target})
        endif(NOT EXISTS ${CMAKE_BINARY_DIR}/doc/.${target})

        #----------------------------------------------------------------------#
        # Create absolute directory pathes from relative input
        #----------------------------------------------------------------------#

        set(_directory ${CMAKE_CURRENT_SOURCE_DIR}/${directory})
        set(_config ${CMAKE_CURRENT_SOURCE_DIR}/doc/${config})

        #----------------------------------------------------------------------#
        # Process extra args
        #
        # Note: calling CMake's set function escapes spaces, so it is
        # easier to use the --option= format for pandoc options
        #----------------------------------------------------------------------#

        set(pandoc_options "--from=markdown+raw_tex+header_attributes")

        if(extra_PANDOC_OPTIONS)
            set(pandoc_options ${pandoc_options} ${extra_PANDOC_OPTIONS})
        endif(extra_PANDOC_OPTIONS)

        #----------------------------------------------------------------------#
        # Process image args
        #
        # If the user has specified a glob, use it to copy all matching
        # files into the intermediate file directory.
        #----------------------------------------------------------------------#

        if(extra_IMAGE_GLOB)
            file(GLOB_RECURSE _IMAGE_FILES ${_directory}/${extra_IMAGE_GLOB})

            foreach(img ${_IMAGE_FILES})
                get_filename_component(_img ${img} NAME_WE)
                get_filename_component(_img_name ${img} NAME)
                add_custom_target(${target}_private_${_img}
                    ${CMAKE_COMMAND} -E copy_if_different ${img}
                        ${CMAKE_BINARY_DIR}/doc/.${target}/${_img_name}
                    DEPENDS ${img}
                    )
                list(APPEND image_dependencies ${target}_private_${_img})
            endforeach(img ${_IMAGE_FILES})
        endif(extra_IMAGE_GLOB)

        #----------------------------------------------------------------------#
        # Glob files in search directory to add as dependency information
        # for the target.
        #----------------------------------------------------------------------#

        file(GLOB_RECURSE _DOCFILES ${_directory}/*.md)

        #----------------------------------------------------------------------#
        # Add a target to generate the aggregate markdown file for the
        # document.
        #----------------------------------------------------------------------#

        add_custom_target(${target}_markdown
            ${CINCH_EXECUTABLE} doc ${CINCH_VERBOSE} ${CINCH_DEVELOPMENT}
                -c ${_config}
                -o ${CMAKE_BINARY_DIR}/doc/.${target}/${target}.md
                ${_directory}
            DEPENDS ${_DOCFILES})

        #----------------------------------------------------------------------#
        # Add the output target to be created by calling pandoc on the
        # aggregate markdown file created in the previous step.
        #
        # NOTE: pandoc doesn't seem to be able to handle files that
        # are not in the current working directory when images are
        # included in the markdown source file.  Fortunately, CMake
        # lets you specify a working directory for a custom target.
        #----------------------------------------------------------------------#

        add_custom_target(${target} ALL
            ${PANDOC_EXECUTABLE} ${pandoc_options} ${target}.md
                -o ${CMAKE_BINARY_DIR}/doc/${output}
            WORKING_DIRECTORY ${CMAKE_BINARY_DIR}/doc/.${target})

        #----------------------------------------------------------------------#
        # Make the target depend on the aggregate markdown file
        # and any images that were globbed.
        #----------------------------------------------------------------------#

        add_dependencies(${target} ${target}_markdown ${image_dependencies})

        #----------------------------------------------------------------------#
        # Add install target
        #----------------------------------------------------------------------#
        
        install(FILES ${CMAKE_BINARY_DIR}/doc/${output}
            DESTINATION share/${CMAKE_PROJECT_NAME})

    endif(ENABLE_DOCUMENTATION)

endfunction(cinch_add_doc)

#------------------------------------------------------------------------------#
# Formatting options for emacs and vim.
# vim: set tabstop=4 shiftwidth=4 expandtab :
#------------------------------------------------------------------------------#
