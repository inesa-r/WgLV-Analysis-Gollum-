Here there is a version of each script used in the GOLLUM pipeline.
they are chosen for relevancy/better showcasing all the tools used in the analysis for the paper, hence why they may not be chronolical by date
the correct order is:

Preparatory work
1) 230209_server_cell profiler splitting into z
2) rings6.cpproj (CellProfiler pipeline)
3) 230710_cell profiler preparing the raw

After CellProfiler

4) 230722_cell profiler assamblying stacks

5) And then if needed extra masks are needed do the relevant"

- 220430_cell profiler making C3-GMAPMask.ijm
- 230118_server_cell profiler making C3-Rab7Mask.ijm
- 230226_cell profiler making C3-Rab7Rab4Mask part 2.ijm
- 230226_server_cell profiler making C3-Rab7Rab4Mask.ijm
- 240110_cell profiler making C3-Rab4Mask.ijm
- 220322_cell profiler classify rings into areas.ijm

6) Analysis bringing everything together
220912_cell profiler analysis2_multiple channels and masks.ijm

   or

230603_cell profiler analysis2_Rab4Rab7.ijm

Extract results onto R

7)220316_GOLLUMprofilesUPDATED.R

8)240112_GOLLUM_results3channels4ref_cleaned

For more info check the paper:
