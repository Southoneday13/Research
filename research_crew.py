"""
ResearchCrew - 基于 Claude API 的多 Agent 科研协作系统
适用于高校博士团队的跨学科研究场景

功能：
  - Literature Agent: 文献检索与综述生成
  - Data Agent: 数据分析与统计检验
  - Visualization Agent: 出版级图表生成
  - Coordinator Agent: 任务拆解与 Agent 调度
  - Token 用量追踪与统计

依赖安装：pip install anthropic matplotlib numpy pandas scipy
"""

import json
import time
import os
from datetime import datetime
from typing import Optional
from dataclasses import dataclass, field

try:
    import anthropic
except ImportError:
    print("请先安装依赖: pip install anthropic")
    exit(1)

# ============================================================
# Token 用量追踪器
# ============================================================

@dataclass
class TokenTracker:
    """全局 Token 用量追踪"""
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

    def summary(self) -> dict:
        elapsed = time.time() - self.start_time
        return {
            "总耗时_秒": round(elapsed, 1),
            "API调用次数": self.call_count,
            "总输入Token": self.total_input_tokens,
            "总输出Token": self.total_output_tokens,
            "总Token消耗": self.total_input_tokens + self.total_output_tokens,
            "各Agent用量": self.agent_usage,
            "预估费用_USD": round(
                self.total_input_tokens * 3 / 1_000_000
                + self.total_output_tokens * 15 / 1_000_000, 4
            ),
        }

    def print_summary(self):
        s = self.summary()
        print("\n" + "=" * 60)
        print("  Token 用量统计报告")
        print("=" * 60)
        print(f"  总耗时: {s['总耗时_秒']} 秒")
        print(f"  API 调用次数: {s['API调用次数']}")
        print(f"  总输入 Token: {s['总输入Token']:,}")
        print(f"  总输出 Token: {s['总输出Token']:,}")
        print(f"  总 Token 消耗: {s['总Token消耗']:,}")
        print(f"  预估费用: ${s['预估费用_USD']}")
        print("-" * 60)
        for agent, usage in s["各Agent用量"].items():
            total = usage["input"] + usage["output"]
            print(f"  [{agent}] 调用{usage['calls']}次 | "
                  f"输入:{usage['input']:,} 输出:{usage['output']:,} 合计:{total:,}")
        print("=" * 60)
        return s


# ============================================================
# 基础 Agent 类
# ============================================================

class BaseAgent:
    def __init__(self, name: str, client: anthropic.Anthropic,
                 tracker: TokenTracker, model: str = "claude-sonnet-4-20250514"):
        self.name = name
        self.client = client
        self.tracker = tracker
        self.model = model
        self.history: list[dict] = []

    def chat(self, system_prompt: str, user_message: str,
             temperature: float = 0.3) -> str:
        self.history.append({"role": "user", "content": user_message})
        response = self.client.messages.create(
            model=self.model,
            max_tokens=4096,
            temperature=temperature,
            system=system_prompt,
            messages=self.history,
        )
        reply = response.content[0].text
        self.history.append({"role": "assistant", "content": reply})
        self.tracker.record(self.name, response.usage.input_tokens,
                            response.usage.output_tokens)
        return reply


# ============================================================
# Literature Agent - 文献智能体
# ============================================================

LITERATURE_SYSTEM = """你是一位资深的学术文献分析专家。你的任务是：
1. 根据用户提供的研究主题，分析该领域的核心研究方向
2. 识别关键理论框架和研究方法
3. 指出当前研究的空白（Research Gap）
4. 输出结构化的文献综述框架

输出格式要求：
- 使用中文
- 包含：研究背景、主要方向（3-5个）、关键发现、研究空白、建议方向
- 每个方向列出2-3个代表性研究（可模拟引用）"""


class LiteratureAgent(BaseAgent):
    def __init__(self, client, tracker):
        super().__init__("Literature_Agent", client, tracker)

    def analyze_topic(self, topic: str) -> str:
        print(f"  [Literature Agent] 正在分析研究主题: {topic}")
        prompt = f"""请针对以下研究主题进行系统性文献分析：

研究主题：{topic}

请输出完整的文献综述框架，包含研究背景、主要研究方向、关键发现和研究空白。"""
        result = self.chat(LITERATURE_SYSTEM, prompt)
        print(f"  [Literature Agent] 分析完成，输出 {len(result)} 字符")
        return result

    def extract_gaps(self, literature_review: str) -> str:
        print(f"  [Literature Agent] 正在提取研究空白...")
        prompt = f"""基于以下文献综述，提取3-5个最值得深入的研究空白，
并为每个空白提出具体的研究问题：

{literature_review}"""
        result = self.chat(LITERATURE_SYSTEM, prompt)
        print(f"  [Literature Agent] 研究空白提取完成")
        return result


# ============================================================
# Data Agent - 数据分析智能体
# ============================================================

DATA_SYSTEM = """你是一位数据分析与统计专家。你的任务是：
1. 接收数据描述或数据集摘要，设计分析方案
2. 推荐合适的统计方法（t检验、ANOVA、回归分析等）
3. 生成可复现的 Python 分析代码
4. 解释统计结果的学术意义

输出要求：
- 提供完整的 Python 代码（使用 pandas/scipy/statsmodels）
- 包含数据预处理、分析、结果解释三个部分
- 对统计显著性进行学术解读"""


class DataAgent(BaseAgent):
    def __init__(self, client, tracker):
        super().__init__("Data_Agent", client, tracker)

    def design_analysis(self, research_question: str, data_description: str) -> str:
        print(f"  [Data Agent] 正在设计分析方案...")
        prompt = f"""研究问题：{research_question}

数据描述：{data_description}

请设计完整的数据分析方案，包括：
1. 数据预处理步骤
2. 推荐的统计方法及理由
3. 完整的 Python 分析代码
4. 结果解读框架"""
        result = self.chat(DATA_SYSTEM, prompt)
        print(f"  [Data Agent] 分析方案设计完成")
        return result

    def generate_report(self, analysis_results: str) -> str:
        print(f"  [Data Agent] 正在生成分析报告...")
        prompt = f"""基于以下分析结果，生成一份适合放入论文的统计分析报告：

{analysis_results}

要求包含：描述性统计、推断统计结果、效应量、置信区间、学术解读。"""
        result = self.chat(DATA_SYSTEM, prompt)
        print(f"  [Data Agent] 分析报告生成完成")
        return result


# ============================================================
# Visualization Agent - 绘图智能体
# ============================================================

VISUALIZATION_SYSTEM = """你是一位学术可视化专家，专注于生成出版级图表。
你的任务是：
1. 根据数据特征选择最合适的图表类型
2. 生成符合 Nature/Science 期刊规范的 matplotlib 代码
3. 确保配色、字体、标注均符合学术出版标准
4. 支持根据反馈迭代修改

规范要求：
- 字体：Arial/Helvetica，标题12pt，轴标签11pt，刻度9pt
- 配色：使用色盲友好的调色板（如 colorblind-safe palette）
- 分辨率：至少 300 DPI
- 包含误差线、显著性标注（* p<0.05, ** p<0.01, *** p<0.001）"""


class VisualizationAgent(BaseAgent):
    def __init__(self, client, tracker):
        super().__init__("Visualization_Agent", client, tracker)

    def generate_chart_code(self, data_description: str,
                            chart_type: str = "auto") -> str:
        print(f"  [Visualization Agent] 正在生成图表代码...")
        prompt = f"""数据描述：{data_description}
期望图表类型：{chart_type}

请生成完整的 matplotlib Python 代码，要求：
1. 符合学术出版规范（Nature/Science 风格）
2. 使用模拟数据演示效果
3. 包含完整的标注、图例、误差线
4. 代码可直接运行"""
        result = self.chat(VISUALIZATION_SYSTEM, prompt)
        print(f"  [Visualization Agent] 图表代码生成完成")
        return result

    def refine_chart(self, original_code: str, feedback: str) -> str:
        print(f"  [Visualization Agent] 正在根据反馈修改图表...")
        prompt = f"""原始图表代码：
{original_code}

修改要求：{feedback}

请输出修改后的完整代码。"""
        result = self.chat(VISUALIZATION_SYSTEM, prompt)
        print(f"  [Visualization Agent] 图表修改完成")
        return result


# ============================================================
# Coordinator Agent - 协调智能体
# ============================================================

COORDINATOR_SYSTEM = """你是 ResearchCrew 的协调智能体（Coordinator）。
你的职责是：
1. 接收用户的科研任务，拆解为子任务
2. 调度 Literature/Data/Visualization Agent 执行
3. 整合各 Agent 的输出，形成完整的研究成果
4. 识别 Agent 输出之间的冲突并仲裁

输出格式：
- 任务拆解清单（编号列表）
- 每个子任务分配给哪个 Agent
- 预期产出说明
- 各子任务之间的依赖关系"""


class CoordinatorAgent(BaseAgent):
    def __init__(self, client, tracker, literature: LiteratureAgent,
                 data: DataAgent, visualization: VisualizationAgent):
        super().__init__("Coordinator_Agent", client, tracker)
        self.literature = literature
        self.data = data
        self.visualization = visualization

    def plan_research(self, research_question: str) -> str:
        print(f"\n{'='*60}")
        print(f"  [Coordinator] 收到研究任务: {research_question}")
        print(f"{'='*60}")
        prompt = f"""研究任务：{research_question}

请将此任务拆解为具体的子任务，说明每个子任务应由哪个Agent完成，
以及子任务之间的依赖关系。"""
        result = self.chat(COORDINATOR_SYSTEM, prompt)
        print(f"  [Coordinator] 任务规划完成")
        return result

    def execute_pipeline(self, research_question: str) -> dict:
        """执行完整的研究流水线"""
        print(f"\n{'#'*60}")
        print(f"  ResearchCrew 多 Agent 协作流水线启动")
        print(f"  研究问题: {research_question}")
        print(f"{'#'*60}")

        results = {}

        # Step 1: 任务规划
        print(f"\n--- Step 1: 任务规划 ---")
        results["task_plan"] = self.plan_research(research_question)

        # Step 2: 文献分析
        print(f"\n--- Step 2: 文献分析 ---")
        results["literature_review"] = self.literature.analyze_topic(
            research_question
        )

        # Step 3: 提取研究空白
        print(f"\n--- Step 3: 研究空白提取 ---")
        results["research_gaps"] = self.literature.extract_gaps(
            results["literature_review"]
        )

        # Step 4: 数据分析方案
        print(f"\n--- Step 4: 数据分析方案设计 ---")
        results["analysis_plan"] = self.data.design_analysis(
            research_question,
            "基于文献分析的研究框架，假设有一组实验数据需要分析"
        )

        # Step 5: 生成分析报告
        print(f"\n--- Step 5: 统计分析报告 ---")
        results["analysis_report"] = self.data.generate_report(
            results["analysis_plan"]
        )

        # Step 6: 可视化
        print(f"\n--- Step 6: 学术图表生成 ---")
        results["visualization_code"] = self.visualization.generate_chart_code(
            f"研究主题: {research_question}，包含多组对比实验数据",
            "组合图（柱状图+散点图+误差线）"
        )

        # Step 7: 整合总结
        print(f"\n--- Step 7: 成果整合 ---")
        summary_prompt = f"""请基于以下各Agent的输出，生成一份完整的研究工作简报：

【文献综述】{results['literature_review'][:1000]}...

【研究空白】{results['research_gaps'][:500]}...

【分析方案】{results['analysis_plan'][:500]}...

请输出：
1. 研究总结（200字）
2. 关键发现（3-5条）
3. 下一步计划"""
        results["final_summary"] = self.chat(COORDINATOR_SYSTEM, summary_prompt)
        print(f"  [Coordinator] 成果整合完成")

        return results


# ============================================================
# 主程序入口
# ============================================================

def main():
    print("""
    ╔══════════════════════════════════════════════════════╗
    ║     ResearchCrew - 多 Agent 科研协作系统 v1.0       ║
    ║     适用于高校博士团队跨学科研究场景               ║
    ╚══════════════════════════════════════════════════════╝
    """)

    # 初始化客户端
    api_key = os.environ.get("ANTHROPIC_API_KEY")
    if not api_key:
        print("请设置环境变量 ANTHROPIC_API_KEY 后运行")
        print("示例: export ANTHROPIC_API_KEY=sk-ant-xxxxx")
        return

    client = anthropic.Anthropic(api_key=api_key)
    tracker = TokenTracker()

    # 初始化各 Agent
    print("正在初始化 Agent 系统...")
    literature_agent = LiteratureAgent(client, tracker)
    data_agent = DataAgent(client, tracker)
    viz_agent = VisualizationAgent(client, tracker)
    coordinator = CoordinatorAgent(
        client, tracker, literature_agent, data_agent, viz_agent
    )
    print("Agent 系统初始化完成\n")

    # 示例研究问题（可替换为实际课题）
    research_question = """
    人工智能辅助的跨学科文献综述方法研究：
    探索LLM驱动的多Agent系统在学术文献分析、
    数据处理与可视化中的应用效果与效率提升。
    """

    # 执行完整流水线
    results = coordinator.execute_pipeline(research_question)

    # 输出结果摘要
    print("\n" + "=" * 60)
    print("  流水线执行完成 - 结果摘要")
    print("=" * 60)
    for key, value in results.items():
        preview = str(value)[:150].replace("\n", " ")
        print(f"  [{key}] {preview}...")
    print("=" * 60)

    # 打印 Token 用量统计
    usage_report = tracker.print_summary()

    # 保存完整报告
    report_path = "research_crew_report.json"
    with open(report_path, "w", encoding="utf-8") as f:
        json.dump({
            "research_question": research_question.strip(),
            "execution_time": datetime.now().isoformat(),
            "token_usage": usage_report,
            "results_summary": {k: str(v)[:500] for k, v in results.items()},
        }, f, ensure_ascii=False, indent=2)
    print(f"\n完整报告已保存至: {report_path}")


if __name__ == "__main__":
    main()
