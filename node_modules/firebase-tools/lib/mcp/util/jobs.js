"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.jobTracker = void 0;
class JobTracker {
    constructor() {
        this.jobs = new Map();
    }
    createJob(id) {
        this.jobs.set(id, {
            status: "running",
            progress: 0,
            logs: [],
        });
    }
    updateJob(id, updates) {
        const job = this.jobs.get(id);
        if (job) {
            Object.assign(job, updates);
        }
    }
    addLog(id, log) {
        const job = this.jobs.get(id);
        if (job) {
            job.logs.push(log);
        }
    }
    getJob(id) {
        return this.jobs.get(id);
    }
}
exports.jobTracker = new JobTracker();
