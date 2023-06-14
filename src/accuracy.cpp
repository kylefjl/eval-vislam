#include "benchmark.h"
using namespace benchmark;

int main(int argc, char* argv[]) {
    if (argc < 3 || argc > 4) {
        fputs("Usage:\n  accuracy <groundtruth> <input> <fix scale>", stderr);
        return EXIT_FAILURE;
    }

    std::string dataset_root(argv[1]);
    std::string input_filename(argv[2]);
    bool fix_scale = false;

    if (argc == 3) {
        fix_scale = false;
    } else {
        fix_scale = (std::atoi(argv[3]) != 0);
    }

    CameraDataset cam_dataset;
    ImuDataset imu_dataset;
    ViconDataset vic_dataset;

    cam_dataset.load(dataset_root + "/camera");
    imu_dataset.load(dataset_root + "/imu");
    vic_dataset.load(dataset_root + "/groundtruth"); // gt has same format to vicon
    vic_dataset.data.save(dataset_root + "/groundtruth/data.txt");

    auto [gt_trajectory, in_trajectory] = get_synchronized_data(input_filename, vic_dataset, cam_dataset, imu_dataset);

    // solve S R T
    std::vector<vector<3>> gt_positions, in_positions;
    for (size_t i = 0; i < gt_trajectory.size(); ++i) {
        if (is_valid_pose(in_trajectory[i])) {
            gt_positions.push_back(gt_trajectory[i].p);
            in_positions.push_back(in_trajectory[i].p);
        }
    }

    auto [s, q, t] = umeyama(gt_positions, in_positions, fix_scale);

    // transform poses to align with gt
    for (size_t i = 0; i < in_trajectory.size(); ++i) {
        if (is_valid_pose(in_trajectory[i])) {
            in_trajectory[i].q = q * in_trajectory[i].q;
            in_trajectory[i].p = (q * in_trajectory[i].p + t) / s;
        }
    }

    // evaluate ape/rpe/are/rre
    double APE = 0, ARE = 0, Acount = 0;
    for (size_t i = 0; i < in_trajectory.size(); ++i) {
        if (is_valid_pose(in_trajectory[i])) {
            vector<3> p_error = in_trajectory[i].p - gt_trajectory[i].p;
            vector<3> q_error = logmap(in_trajectory[i].q.conjugate() * gt_trajectory[i].q);
            APE += p_error.squaredNorm();
            ARE += q_error.squaredNorm();
            Acount++;
        }
    }
    Acount = std::max(Acount, 1.0);
    APE = sqrt(APE / Acount) * 1e3;
    ARE = sqrt(ARE / Acount) * 180 / M_PI;

    double RPE = 0, RRE = 0, Rcount = 0;
    for (size_t j = 1; j < in_trajectory.size(); ++j) {
        size_t i = j - 1;
        if (is_valid_pose(in_trajectory[i]) && is_valid_pose(in_trajectory[j])) {
            vector<3> in_p_diff = in_trajectory[j].p - in_trajectory[i].p;
            vector<3> gt_p_diff = gt_trajectory[j].p - gt_trajectory[i].p;
            vector<3> in_q_diff = logmap(in_trajectory[i].q.conjugate() * in_trajectory[j].q);
            vector<3> gt_q_diff = logmap(gt_trajectory[i].q.conjugate() * gt_trajectory[j].q);
            RPE += (in_p_diff - gt_p_diff).squaredNorm();
            RRE += (in_q_diff - gt_q_diff).squaredNorm();
            Rcount++;
        }
    }
    Rcount = std::max(Rcount, 1.0);
    RPE = sqrt(RPE / Rcount) * 1e3;
    RRE = sqrt(RRE / Rcount) * 180 / M_PI;

    // evaluate completeness
    // here we used an assumption: input is having fixed frame rate
    double Ccount = 0;
    for (size_t i = 0; i < in_trajectory.size(); ++i) {
        if (is_valid_pose(in_trajectory[i])) {
            vector<3> p_error = in_trajectory[i].p - gt_trajectory[i].p;
            if (p_error.norm() <= 0.1) {
                Ccount++;
            }
        }
    }
    double CMPL = Ccount / in_trajectory.size();

    printf("Scale: %.3f%%\nAPE:   %.3f [mm]\nRPE:   %.3f [mm]\nARE:   %.3f [deg]\nRRE:   %.3f [deg]\nCMPL:  %.3f%%\n", s * 1e2, APE, RPE, ARE, RRE, CMPL * 1e2);

    return EXIT_SUCCESS;
}
