import subprocess
import glob
import argparse
import os

def create_arg_parser():
    parser = argparse.ArgumentParser(description="Create animations for a trained model")
    parser.add_argument("--model_dir", help="Path to model directory", required=True)
    parser.add_argument("--val_data_dir", help="Path to validation data set directory", required=True)
    return parser

if __name__ == "__main__":
    parser = create_arg_parser()
    args = parser.parse_args()

    model_dir = args.model_dir
    test_records = glob.glob(args.val_data_dir +"/*.tfrecord")

    for record in test_records:
        filename = os.path.splitext(os.path.basename(record))[0]
        subprocess.run(["python", "inference_video.py", 
                        "--labelmap_path", "label_map.pbtxt", 
                        "--model_path", os.path.join(model_dir,"exported/saved_model"), 
                        "--config_path", os.path.join(model_dir,"pipeline_new.config"), 
                        "--tf_record_path", record,
                        "--output_path", os.path.join(model_dir, filename+".gif")])