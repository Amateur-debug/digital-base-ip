import os
import random
import sys
from pathlib import Path

import cocotb
from cocotb.clock import Clock
from cocotb.handle import SimHandleBase
from cocotb.queue import Queue
from cocotb.triggers import Timer, RisingEdge, ReadWrite, NextTimeStep, Edge
from cocotb.types import LogicArray, Range
from cocotb.runner import get_runner

@cocotb.test()
async def fma_fpany_test(dut):

    cocotb.start_soon(Clock(dut.clock, 10, units="ns").start())

    # dut.reset.value = 1
    # await Timer(5, units="ns")
    # dut.reset.value = 0

    await RisingEdge(dut.clock) 
    dut.src0.value = 0
    dut.src1.value = 0
    dut.src2.value = 0
    await ReadWrite()
    await ReadWrite()
    dut._log.info(f"BIAS_NEW: {dut.BIAS_NEW.value}")
    dut._log.info(f"BIAS_MUL: {dut.BIAS_MUL.value}")
    dut._log.info(f"BIAS_ADD: {dut.BIAS_ADD.value}")
    dut._log.info(f"result: {dut.result.value}")

    await RisingEdge(dut.clock)
    dut.src0.value = 0x3C00
    dut.src1.value = 0x3C00
    dut.src2.value = 0x3F800000
    await ReadWrite()
    await ReadWrite()
    dut._log.info(f"result: {dut.result.value}")

    await RisingEdge(dut.clock)


def test_fma_fpany():
    
    hdl_toplevel_lang = os.getenv("HDL_TOPLEVEL_LANG", "verilog")
    sim = os.getenv("SIM", "icarus")

    proj_path = Path(__file__).resolve().parent.parent
    common_path = Path("/hpc/home/connect.xchen740/workspace/digital-base-ip-main")
    # equivalent to setting the PYTHONPATH environment variable
    sys.path.append(str(proj_path / "sim"))

    sources = [
        proj_path / "source" / "fma_fpany.v",
        common_path / "encoder" / "source" / "priority_encoder.v",
        common_path / "ram" / "source" / "ram_dp.v",
        common_path / "flip-flop" / "dff" / "source" / "dff.v",
        common_path / "flip-flop" / "dff" / "source" / "dff_en.v",
        common_path / "flip-flop" / "dff" / "source" / "dff_ar.v",
        common_path / "flip-flop" / "dff" / "source" / "dff_aren.v"
    ]

    build_args = []
    test_args = []

    # equivalent to setting the PYTHONPATH environment variable
    sys.path.append(str(proj_path / "tb"))

    runner = get_runner(sim)
    runner.build(
        sources = sources,
        hdl_toplevel = "fma_fpany",
        build_dir = "./build",
        always = True,
        waves = True,
        build_args=build_args,
    )
    runner.test(
        hdl_toplevel="fma_fpany", test_module="test_fma_fpany", waves=True
    )


if __name__ == "__main__":
    test_fma_fpany()