-- Fix Encrypted Content Type Mismatch Migration
-- Fixes the bytea to text type mismatch in get_user_conversations_enhanced function

DROP FUNCTION IF EXISTS get_user_conversations_enhanced(UUID);

CREATE OR REPLACE FUNCTION get_user_conversations_enhanced(user_uuid UUID)
RETURNS TABLE (
    conversation_id UUID,
    conversation_type TEXT,
    conversation_name TEXT,
    conversation_avatar_url TEXT,
    group_id UUID,
    group_name TEXT,
    participant_count BIGINT,
    latest_message_id UUID,
    latest_message_content TEXT,
    latest_message_sender_id UUID,
    latest_message_sender_username TEXT,
    latest_message_created_at TIMESTAMPTZ,
    unread_count BIGINT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        c.id as conversation_id,
        c.type as conversation_type,
        CASE 
            WHEN c.type = 'direct' THEN 
                (SELECT u.display_name FROM users u 
                 JOIN conversation_participants cp2 ON u.id = cp2.user_id 
                 WHERE cp2.conversation_id = c.id AND u.id != user_uuid LIMIT 1)
            WHEN c.type = 'room' THEN c.name
            ELSE c.name
        END as conversation_name,
        CASE 
            WHEN c.type = 'direct' THEN 
                (SELECT u.avatar_url FROM users u 
                 JOIN conversation_participants cp3 ON u.id = cp3.user_id 
                 WHERE cp3.conversation_id = c.id AND u.id != user_uuid LIMIT 1)
            ELSE c.avatar_url
        END as conversation_avatar_url,
        c.group_id,
        g.name as group_name,
        (SELECT COUNT(*) FROM conversation_participants cp4 WHERE cp4.conversation_id = c.id) as participant_count,
        lm.id as latest_message_id,
        CASE 
            WHEN lm.encrypted_content IS NOT NULL THEN 
                convert_from(lm.encrypted_content, 'UTF8')::TEXT
            ELSE NULL
        END as latest_message_content,
        lm.sender_id as latest_message_sender_id,
        lu.username as latest_message_sender_username,
        lm.created_at as latest_message_created_at,
        (SELECT COUNT(*) FROM messages m 
         LEFT JOIN message_status ms ON m.id = ms.message_id AND ms.user_id = user_uuid
         WHERE m.conversation_id = c.id 
         AND m.sender_id != user_uuid 
         AND (ms.status IS NULL OR ms.status != 'read')
         AND m.deleted_at IS NULL) as unread_count
    FROM conversations c
    JOIN conversation_participants cp ON c.id = cp.conversation_id
    LEFT JOIN groups g ON c.group_id = g.id
    LEFT JOIN LATERAL (
        SELECT m.* FROM messages m 
        WHERE m.conversation_id = c.id 
        AND m.deleted_at IS NULL
        ORDER BY m.created_at DESC 
        LIMIT 1
    ) lm ON true
    LEFT JOIN users lu ON lm.sender_id = lu.id
    WHERE cp.user_id = user_uuid 
    AND cp.left_at IS NULL
    ORDER BY COALESCE(lm.created_at, c.created_at) DESC;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant permissions
GRANT EXECUTE ON FUNCTION get_user_conversations_enhanced(UUID) TO authenticated;

-- Add comment
COMMENT ON FUNCTION get_user_conversations_enhanced(UUID) IS 'Gets all user conversations with proper bytea to text conversion for encrypted_content';