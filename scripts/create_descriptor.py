#!/usr/bin/env python

from argparse import ArgumentParser
import boutiques.creator as bc


def makeParser():
    parser = ArgumentParser(description="This is an end-to-end connectome \
                            estimation pipeline from sMRI and DTI images")

    parser.add_argument('bids_dir', help='The directory with the input dataset'
                        ' formatted according to the BIDS standard.')
    parser.add_argument('output_dir', help='The directory where the output '
                        'files should be stored. If you are running group '
                        'level analysis this folder should be prepopulated '
                        'with the results of the participant level analysis.')
    parser.add_argument('analysis_level', help='Level of the analysis that '
                        'will be performed. Multiple participant level '
                        'analyses can be run independently (in parallel) '
                        'using the same output_dir.',
                        choices=['participant', 'group'])
    parser.add_argument('modality', help='Modality of graphs that \
                        are being generated.', choices=['dwi', 'func'])
    parser.add_argument('--participant_label', help='The label(s) of the '
                        'participant(s) that should be analyzed. The label '
                        'corresponds to sub-<participant_label> from the BIDS '
                        'spec (so it does not include "sub-"). If this '
                        'parameter is not provided all subjects should be '
                        'analyzed. Multiple participants can be specified '
                        'with a space separated list.', nargs="+")
    parser.add_argument('--session_label', help='The label(s) of the '
                        'session that should be analyzed. The label '
                        'corresponds to ses-<participant_label> from the BIDS '
                        'spec (so it does not include "ses-"). If this '
                        'parameter is not provided all sessions should be '
                        'analyzed. Multiple sessions can be specified '
                        'with a space separated list.')
    parser.add_argument('--bucket', action='store', help='The name of '
                        'an S3 bucket which holds BIDS organized data. You '
                        'must have built your bucket with credentials to the '
                        'S3 bucket you wish to access.')
    parser.add_argument('--remote_path', action='store', help='The path to '
                        'the data on your S3 bucket. The data will be '
                        'downloaded to the provided bids_dir on your machine.')
    parser.add_argument('--push_data', action='store_true', help='flag to '
                        'push derivatives back up to S3.', default=False)
    parser.add_argument('--dataset', action='store', help='The name of '
                        'the dataset you are perfoming QC on.')
    parser.add_argument('--atlas', action='store', help='The atlas '
                        'being analyzed in QC (if you only want one).')
    parser.add_argument('--minimal', action='store_true', help='Determines '
                        'whether to show a minimal or full set of plots.',
                        default=False)
    parser.add_argument('--hemispheres', action='store_true', help='Whether '
                        'or not to break degrees into hemispheres or not',
                        default=False)
    parser.add_argument('--log', action='store_true', help='Determines '
                        'axis scale for plotting.', default=False)
    parser.add_argument('--debug', action='store_true', help='flag to store '
                        'temp files along the path of processing.',
                        default=False)
    parser.add_argument("--stc", action="store", help='A file for slice '
                        'timing correction. Options are a TR sequence file '
                        '(where each line is the shift in TRs), '
                        'up (ie, bottom to top), down (ie, top to bottom), '
                        'and interleaved.', default=None)
    return parser


if __name__ == "__main__":
    myparser = makeParser()

    newDescriptor = bc.CreateDescriptor(myparser, execname="ndmg_bids")
    newDescriptor.save("ndmg_new.json")
