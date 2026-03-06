# This file is part of Telegram Desktop,
# the official desktop application for the Telegram messaging service.
#
# For license and copyright information please follow this link:
# https://github.com/telegramdesktop/tdesktop/blob/master/LEGAL

function(telegram_add_apple_swift_runtime target_name)
    if (NOT APPLE)
        return()
    endif()

    if (CMAKE_GENERATOR STREQUAL "Xcode")
        target_link_options(${target_name}
        PRIVATE
            "-L$(TOOLCHAIN_DIR)/usr/lib/swift/macosx"
        )
    elseif (CMAKE_Swift_COMPILER)
        get_filename_component(swift_compiler_dir "${CMAKE_Swift_COMPILER}" DIRECTORY)
        get_filename_component(swift_toolchain_usr_dir "${swift_compiler_dir}" DIRECTORY)
        set(swift_runtime_lib_dir "${swift_toolchain_usr_dir}/lib/swift/macosx")
        if (EXISTS "${swift_runtime_lib_dir}")
            target_link_options(${target_name}
            PRIVATE
                "-L${swift_runtime_lib_dir}"
            )
        endif()
    endif()

    target_link_options(${target_name}
    PRIVATE
        "-Wl,-rpath,/usr/lib/swift"
        "-Wl,-rpath,@executable_path/../Frameworks"
    )

    add_custom_command(TARGET ${target_name} POST_BUILD
        COMMAND mkdir -p $<TARGET_FILE_DIR:${target_name}>/../Frameworks
        COMMAND xcrun swift-stdlib-tool
            --copy
            --platform macosx
            --scan-executable $<TARGET_FILE:${target_name}>
            --destination $<TARGET_FILE_DIR:${target_name}>/../Frameworks
        VERBATIM
    )
endfunction()
