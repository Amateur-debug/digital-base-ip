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
async def cam_test(dut):

    cocotb.start_soon(Clock(dut.clock, 10, units="ns").start())

    dut.reset.value = 1
    await Timer(5, units="ns")
    dut.reset.value = 0
    
    while dut.wready.value == 0:
        await RisingEdge(dut.clock)
        await ReadWrite()

    dut._log.info(f"state: {dut.state.value}") 
    dut.waddr.value = 1
    dut.wdata.value = 11
    dut.delete.value = 0
    dut.wen.value = 1

    await RisingEdge(dut.clock)
    await ReadWrite()
    dut.wen.value = 0

    while dut.wready.value == 0:
        await RisingEdge(dut.clock)
        await ReadWrite()

    dut.compare_data.value = 11
    await RisingEdge(dut.clock)
    await ReadWrite()
    dut._log.info(f"match: {dut.match.value}")
    dut._log.info(f"match_addr: {dut.match_addr.value}")

def test_cam_bram():
    
    hdl_toplevel_lang = os.getenv("HDL_TOPLEVEL_LANG", "verilog")
    sim = os.getenv("SIM", "icarus")

    proj_path = Path(__file__).resolve().parent.parent
    common_path = Path(os.getenv("COMMON_PATH"))
    # equivalent to setting the PYTHONPATH environment variable
    sys.path.append(str(proj_path / "tb"))

    sources = [
        proj_path / "source" / "cam.v",
        common_path / "ram" / "source" / "ram_dp.v",
        common_path / "flip-flop" / "source" / "dff.v",
        common_path / "flip-flop" / "source" / "dff_en.v",
        common_path / "flip-flop" / "source" / "dff_ar.v",
        common_path / "flip-flop" / "source" / "dff_aren.v",
        common_path / "encoder" / "source" / "priority_encoder.v"
    ]

    build_args = []
    test_args = []

    # equivalent to setting the PYTHONPATH environment variable
    sys.path.append(str(proj_path / "tb"))

    runner = get_runner(sim)
    runner.build(
        sources=sources,
        hdl_toplevel="cam",
        always=True,
        waves=True,
        build_args=build_args,
    )
    runner.test(
        hdl_toplevel="cam", test_module="test_cam", waves=True
    )


if __name__ == "__main__":
    test_cam()