def _hex_impl(ctx):
    output = ctx.outputs.out
    input = ctx.file.src
    ctx.action(
        inputs=[
                input,
                ctx.executable._objcopy,
                ctx.executable._size
        ],
        outputs = [output],
        progress_message = "Creating code and data HEX file from %s" % input.short_path,
        command="%s -j .text -j .data -O ihex %s %s; %s --format=avr -C --mcu=%s %s" % ( \
                ctx.executable._objcopy.path, 
                input.path, 
                output.path, 
                ctx.executable._size.path, 
                ctx.var["MCU"], 
                input.path
         )
    )


hex = rule(
    implementation=_hex_impl,
    attrs={
        "src": attr.label(mandatory=True, allow_files=True, single_file=True),
        "_size": attr.label(
                allow_files=True, 
                single_file=True, 
                executable=True, 
                cfg="host", 
                default=Label("@avr_tools//avr_gcc:size")
        ),
        "_objcopy": attr.label(
                allow_files=True,
                single_file=True,
                executable=True,
                cfg="host",
                default=Label("@avr_tools//avr_gcc:objcopy")
        ),
    },
    outputs={"out": "%{src}.hex"},
)



def _eeprom_impl(ctx):
    output = ctx.outputs.out
    input = ctx.file.src
    ctx.action(
        inputs=[
                input,
                ctx.executable._objcopy
        ],
        outputs = [output],
        progress_message = "Generating eeprom HEX file from %s" % input.short_path,
        command="%s -j .eeprom --change-section-lma .eeprom=0 -O ihex %s %s" % ( \
                ctx.executable._objcopy.path, 
                input.path, 
                output.path, 
         )
    )


eeprom = rule(
    implementation=_eeprom_impl,
    attrs={
        "src": attr.label(mandatory=True, allow_files=True, single_file=True),
        "_objcopy": attr.label(
                allow_files=True,
                single_file=True,
                executable=True,
                cfg="host",
                default=Label("@avr_tools//avr_gcc:objcopy")
        ),
    },
    outputs={"out": "%{src}.eeprom"},
)

