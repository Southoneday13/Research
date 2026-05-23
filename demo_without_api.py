"""
ResearchCrew 本地演示版（无需 API Key）
用于展示系统架构与多 Agent 协作逻辑

运行方式: python demo_without_api.py
"""

import json
import time
import random
from datetime import datetime
from dataclasses import dataclass, field


# ============================================================
# Token 模拟追踪器
# ============================================================

@dataclass
class TokenTracker:
    total_input_tokens: int = 0
    total_output_tokens: int = 0
    call_count: int = 0
    agent_usage: dict = field(default_factory=dict)
    start_time: float = field(default_factory=time.time)

    def record(self, agent_name: str, input_tokens: int, output_tokens: int):
        self.total_input_tokens += input_tokens
        self.total_output_tokens += output_tokens
        self.call_count += 1
        if agent_name not in self.agent_usage:
            self.agent_usage[agent_name] = {"input": 0, "output": 0, "calls": 0}
        self.agent_usage[agent_name]["input"] += input_tokens
        self.agent_usage[agent_name]["output"] += output_tokens
        self.agent_usage[agent_name]["calls"] += 1

    def print_summary(self):
        elapsed = time.time() - self.start_time
        total = self.total_input_tokens + self.total_output_tokens
        print("\n" + "=" * 60)
        print("  Token 用量统计报告（模拟数据）")
        print("=" * 60)
        print(f"  总耗时: {round(elapsed, 1)} 秒")
        print(f"  API 调用次数: {self.call_count}")
        print(f"  总输入 Token: {self.total_input_tokens:,}")
        print(f"  总输出 Token: {self.total_output_tokens:,}")
        print(f"  总 Token 消耗: {total:,}")
        print("-" * 60)
        for agent, u in self.agent_usage.items():
            t = u["input"] + u["output"]
            print(f"  [{agent}] 调用{u['calls']}次 | "
                  f"输入:{u['input']:,} 输出:{u['output']:,} 合计:{t:,}")
        print("=" * 60)


# ============================================================
# 模拟 Agent 基类
# ============================================================

class SimulatedAgent:
    def __init__(self, name: str, tracker: TokenTracker):
        self.name = name
        self.tracker = tracker

    def simulate_call(self, prompt_tokens: int = 800, output_tokens: int = 1500):
        """模拟一次 API 调用，记录 Token 用量"""
        time.sleep(0.3)  # 模拟网络延迟
        self.tracker.record(self.name, prompt_tokens, output_tokens)
        return output_tokens


# ============================================================
# Literature Agent 模拟
# ============================================================

class LiteratureAgent(SimulatedAgent):
    def analyze_topic(self, topic: str) -> dict:
        print(f"  [Literature Agent] 正在分析研究主题: {topic[:30]}...")
        self.simulate_call(1200, 2800)
        result = {
            "研究背景": f"近年来，{topic}领域受到广泛关注。随着大语言模型(LLM)的发展，"
                        f"AI辅助科研成为新兴研究方向。",
            "主要方向": [
                "方向一：LLM驱动的自动化文献综述生成",
                "方向二：多Agent协作的跨学科知识整合",
                "方向三：AI辅助的实验设计与数据分析",
                "方向四：学术可视化自动化与规范化",
            ],
            "关键发现": [
                "GPT-4在文献摘要任务上达到人类85%的一致性",
                "多Agent系统比单Agent提升40%的任务完成质量",
                "AI辅助绘图可减少70%的图表制作时间",
            ],
            "研究空白": [
                "缺乏针对中文文献的多Agent综述系统",
                "跨学科数据处理流程的自动化程度不足",
                "现有系统缺少Token用量的精细化追踪",
            ]
        }
        print(f"  [Literature Agent] 文献分析完成，识别 {len(result['主要方向'])} 个方向")
        return result

    def extract_gaps(self, review: dict) -> list:
        print(f"  [Literature Agent] 正在提取研究空白...")
        self.simulate_call(1500, 1200)
        gaps = [
            "RQ1: 多Agent系统能否有效提升跨学科文献综述效率？",
            "RQ2: Agent间协作模式对分析质量的影响机制是什么？",
            "RQ3: 如何量化AI辅助科研的效率提升比例？",
        ]
        print(f"  [Literature Agent] 提取了 {len(gaps)} 个研究空白")
        return gaps


# ============================================================
# Data Agent 模拟
# ============================================================

class DataAgent(SimulatedAgent):
    def design_analysis(self, research_question: str) -> dict:
        print(f"  [Data Agent] 正在设计分析方案...")
        self.simulate_call(1000, 1800)
        plan = {
            "数据预处理": "缺失值填充(KNN)、异常值检测(IQR法)、标准化(Z-score)",
            "统计方法": [
                "描述性统计: 均值、标准差、分布检验",
                "推断统计: 独立样本t检验、单因素ANOVA",
                "效应量: Cohen's d, η²",
                "相关分析: Pearson/Spearman相关系数",
            ],
            "推荐工具": "pandas + scipy + statsmodels",
            "代码框架": "详见 analysis_pipeline.py"
        }
        print(f"  [Data Agent] 分析方案设计完成")
        return plan

    def generate_report(self, analysis_plan: dict) -> dict:
        print(f"  [Data Agent] 正在生成统计报告...")
        self.simulate_call(1800, 2500)
        report = {
            "描述性统计": {
                "实验组": {"均值": 85.3, "标准差": 12.4, "N": 50},
                "对照组": {"均值": 72.1, "标准差": 14.8, "N": 50},
            },
            "t检验结果": {
                "t值": 4.82,
                "p值": 0.0000032,
                "显著性": "*** (p < 0.001)",
                "Cohen_d": 0.96,
                "效应解释": "大效应量",
            },
            "置信区间": "95% CI: [8.2, 18.2]",
            "结论": "AI辅助组的文献分析效率显著高于传统方法组"
        }
        print(f"  [Data Agent] 统计报告生成完成")
        return report


# ============================================================
# Visualization Agent 模拟
# ============================================================

class VisualizationAgent(SimulatedAgent):
    def generate_chart(self, data_description: str) -> dict:
        print(f"  [Visualization Agent] 正在生成出版级图表...")
        self.simulate_call(1500, 2200)
        chart_info = {
            "图表类型": "组合图（柱状图 + 散点图 + 误差线）",
            "规范": "Nature/Science 风格",
            "配色": "色盲友好调色板 (#0072B2, #D55E00, #009E73)",
            "字体": "Arial, 标题12pt, 轴标签11pt, 刻度9pt",
            "分辨率": "300 DPI",
            "标注": "显著性标注: * p<0.05, ** p<0.01, *** p<0.001",
            "输出格式": "PDF + PNG 双格式"
        }
        print(f"  [Visualization Agent] 图表生成完成")
        return chart_info


# ============================================================
# Coordinator Agent 模拟
# ============================================================

class CoordinatorAgent(SimulatedAgent):
    def __init__(self, tracker, literature, data, viz):
        super().__init__("Coordinator_Agent", tracker)
        self.literature = literature
        self.data = data
        self.viz = viz

    def execute_pipeline(self, research_question: str) -> dict:
        print(f"\n{'#'*60}")
        print(f"  ResearchCrew 多 Agent 协作流水线启动")
        print(f"  研究问题: {research_question}")
        print(f"{'#'*60}")

        results = {}

        # Step 1: 任务规划
        print(f"\n--- Step 1: 协调智能体 - 任务规划 ---")
        self.simulate_call(800, 1200)
        results["task_plan"] = {
            "子任务数": 5,
            "分配": {
                "Literature_Agent": ["文献检索", "综述生成", "研究空白提取"],
                "Data_Agent": ["分析方案设计", "统计分析", "报告生成"],
                "Visualization_Agent": ["图表设计", "代码生成"],
                "Coordinator_Agent": ["任务规划", "成果整合"],
            }
        }
        print(f"  [Coordinator] 任务规划完成: {results['task_plan']['子任务数']} 个子任务")

        # Step 2: Literature Agent 工作
        print(f"\n--- Step 2: Literature Agent - 文献分析 ---")
        results["literature_review"] = self.literature.analyze_topic(research_question)

        # Step 3: 提取研究空白
        print(f"\n--- Step 3: Literature Agent - 研究空白提取 ---")
        results["research_gaps"] = self.literature.extract_gaps(results["literature_review"])

        # Step 4: Data Agent 工作
        print(f"\n--- Step 4: Data Agent - 分析方案设计 ---")
        results["analysis_plan"] = self.data.design_analysis(research_question)

        # Step 5: 统计报告
        print(f"\n--- Step 5: Data Agent - 统计分析报告 ---")
        results["analysis_report"] = self.data.generate_report(results["analysis_plan"])

        # Step 6: Visualization Agent 工作
        print(f"\n--- Step 6: Visualization Agent - 图表生成 ---")
        results["visualization"] = self.viz.generate_chart(research_question)

        # Step 7: 整合
        print(f"\n--- Step 7: Coordinator - 成果整合 ---")
        self.simulate_call(3000, 1800)
        results["final_summary"] = {
            "研究总结": "本研究构建了基于Claude API的多Agent科研协作系统，"
                       "通过Literature/Data/Visualization三个专业Agent的协作，"
                       "实现了从文献分析到数据处理再到图表生成的全流程自动化。",
            "关键发现": [
                "多Agent协作使文献综述效率提升约80%",
                "自动化数据分析流程减少人工干预60%",
                "标准化图表生成节省70%的制作时间",
            ],
            "下一步计划": [
                "扩展支持更多学科领域的Agent",
                "引入Agent间的反馈迭代机制",
                "建立Token用量优化策略",
            ]
        }
        print(f"  [Coordinator] 成果整合完成")

        return results


# ============================================================
# 主程序
# ============================================================

def main():
    print("""
    ╔══════════════════════════════════════════════════════╗
    ║     ResearchCrew - 多 Agent 科研协作系统 v1.0       ║
    ║     演示模式（模拟 API 调用，展示系统架构）         ║
    ╠══════════════════════════════════════════════════════╣
    ║  Agent 列表:                                        ║
    ║    - Literature Agent   (文献智能体)                ║
    ║    - Data Agent         (数据分析智能体)            ║
    ║    - Visualization Agent(绘图智能体)                ║
    ║    - Coordinator Agent  (协调智能体)                ║
    ╚══════════════════════════════════════════════════════╝
    """)

    tracker = TokenTracker()

    # 初始化 Agent
    print("正在初始化 Agent 系统...")
    lit_agent = LiteratureAgent("Literature_Agent", tracker)
    data_agent = DataAgent("Data_Agent", tracker)
    viz_agent = VisualizationAgent("Visualization_Agent", tracker)
    coordinator = CoordinatorAgent(tracker, lit_agent, data_agent, viz_agent)
    print("Agent 系统初始化完成\n")

    # 执行研究流水线
    research_question = "AI辅助的跨学科文献综述方法研究"

    start = time.time()
    results = coordinator.execute_pipeline(research_question)
    elapsed = time.time() - start

    # 输出结果摘要
    print("\n" + "=" * 60)
    print("  流水线执行完成 - 结果摘要")
    print("=" * 60)
    for key, value in results.items():
        if isinstance(value, dict):
            preview = str(list(value.keys()))[:80]
        elif isinstance(value, list):
            preview = str(value[0])[:80] + "..."
        else:
            preview = str(value)[:80]
        print(f"  [{key}] {preview}")
    print("=" * 60)

    # Token 统计
    tracker.print_summary()

    # 保存报告
    report = {
        "系统信息": {
            "名称": "ResearchCrew 多Agent科研协作系统",
            "版本": "v1.0",
            "Agent数量": 4,
            "运行模式": "演示模式",
        },
        "研究问题": research_question,
        "执行时间": datetime.now().isoformat(),
        "总耗时_秒": round(elapsed, 2),
        "Token统计": {
            "总输入Token": tracker.total_input_tokens,
            "总输出Token": tracker.total_output_tokens,
            "总消耗": tracker.total_input_tokens + tracker.total_output_tokens,
            "API调用次数": tracker.call_count,
            "各Agent用量": tracker.agent_usage,
        },
        "结果摘要": {k: str(v)[:300] for k, v in results.items()},
    }

    with open("demo_report.json", "w", encoding="utf-8") as f:
        json.dump(report, f, ensure_ascii=False, indent=2)
    print(f"\n报告已保存至: demo_report.json")

    print(f"""
    ┌──────────────────────────────────────────────────────┐
    │  演示完成！                                          │
    │                                                      │
    │  本演示展示了 ResearchCrew 的完整工作流程：          │
    │  1. Coordinator 接收任务并拆解                       │
    │  2. Literature Agent 执行文献分析                    │
    │  3. Data Agent 设计分析方案并生成报告               │
    │  4. Visualization Agent 生成出版级图表              │
    │  5. Coordinator 整合所有输出                         │
    │                                                      │
    │  实际运行请设置 ANTHROPIC_API_KEY 环境变量后        │
    │  执行 research_crew.py                               │
    └──────────────────────────────────────────────────────┘
    """)


if __name__ == "__main__":
    main()
