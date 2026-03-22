import 'package:flutter/material.dart';

class ParentScreen extends StatelessWidget {
  const ParentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8E7),
      appBar: AppBar(
        title: const Text('家长模式'),
        backgroundColor: Colors.orange,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // 学习统计
          _buildCard(
            title: '学习统计',
            child: Column(
              children: [
                _buildStatRow('本周阅读绘本', '3本'),
                _buildStatRow('累计阅读绘本', '12本'),
                _buildStatRow('掌握词汇', '45个'),
                _buildStatRow('连续学习', '5天'),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          // 设置
          _buildCard(
            title: '设置',
            child: Column(
              children: [
                _buildSettingItem('每日学习时长', '20分钟'),
                _buildSettingItem('难度等级', 'Level 2'),
                _buildSettingItem('语音提示', '开启'),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          // 关于
          _buildCard(
            title: '关于',
            child: const Column(
              children: [
                ListTile(
                  title: Text('版本'),
                  trailing: Text('1.0.0'),
                ),
                ListTile(
                  title: Text('隐私政策'),
                  trailing: Icon(Icons.arrow_forward_ios, size: 16),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard({required String title, required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(15),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF5D4037),
              ),
            ),
          ),
          const Divider(height: 1),
          child,
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 16),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.orange,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem(String label, String value) {
    return ListTile(
      title: Text(label),
      trailing: Text(
        value,
        style: const TextStyle(color: Colors.orange),
      ),
      onTap: () {
        // 设置项点击
      },
    );
  }
}